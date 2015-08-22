# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../spec_helper'

describe Dromelib::GMail do
  after do
    Dromelib.end!
  end

  let(:clean_environment) do
    {
      'GMAIL_USERNAME' => nil,
      'GMAIL_PASSWORD' => nil,
      'GMAIL_FROM' => nil,
      'GMAIL_SUBJECT_PREFIX' => nil
    }
  end

  let(:environment_vars) do
    {
      'GMAIL_USERNAME' => 'fernan.dogs',
      'GMAIL_PASSWORD' => 'guau!!! guau!!!',
      'GMAIL_FROM' => nil,
      'GMAIL_SUBJECT_PREFIX' => nil
    }
  end

  let(:yaml_content) do
    {
      'gmail' => {
        'username' => 'colgado',
        'password' => 'barking'
      }
    }
  end

  describe 'instance methods' do
    it 'should raise UninitializedError unless Dromelib.init! has been called first' do
      Dromelib::GMail.instance_methods.each do |method| 
        proc do
          Dromelib::GMail.send method
        end.must_raise Dromelib::UninitializedError
      end
    end
  end

  %w(
    username
    password
    from
    subject_prefix
  ).each do |method|
    describe ".#{method} singleton method" do
      it 'should return its value in .dromelib.yml if not present in the environment' do
        ClimateControl.modify clean_environment do
          YAML.stub(:load_file, yaml_content) do
            Dromelib.init!
            Dromelib::GMail.send(method).must_equal yaml_content['gmail'][method]
          end
        end
      end

      it 'should check first the environment variable' do
        ClimateControl.modify environment_vars do
          YAML.stub(:load_file, {}) do
            Dromelib.init!
            Dromelib::GMail.send(method).must_equal environment_vars["GMAIL_#{method.upcase}"]
          end
        end
      end
    end
  end

  describe '.configured? (aka "username+password requirement":)' do
    it 'should work using ENV variables' do
      YAML.stub(:load_file, Dromelib::Config.gem_yaml) do
        ClimateControl.modify environment_vars do
          Dromelib.init!
          assert Dromelib::GMail.configured?,
                 '.username and .password ENV vars. should let us be configured.'
        end
      end
    end
 
    it 'should work using out local .dromelib.yml' do
      YAML.stub(:load_file, yaml_content) do
        ClimateControl.modify clean_environment do
          Dromelib.init!
          assert Dromelib::GMail.configured?,
                 'local .dromelib.yml should let us set the credentials too.'
        end
      end
    end
 
    %w(
      username
      password
    ).each do |required_param|
      it "should be false if the #{required_param} is missing" do
        yaml = yaml_content
        yaml['gmail'][required_param] = nil
        env = environment_vars.merge("GMAIL_#{required_param.upcase}" => nil)
        YAML.stub(:load_file, yaml) do
          ClimateControl.modify env do
            Dromelib.init!
            refute Dromelib::GMail.configured?
          end
        end
      end
   
      it "should be false if the #{required_param} is an empty string" do
        yaml = yaml_content
        yaml_content['gmail'][required_param] = ''
        env = environment_vars.merge("GMAIL_#{required_param.upcase}" => '')
        YAML.stub(:load_file, yaml) do
          ClimateControl.modify env do
            Dromelib.init!
            refute Dromelib::GMail.configured?
          end
        end
      end
    end
  end

  describe '.valid_from?' do
    let(:email) {'valid@email.org'}

    it 'should be true for a valid email' do
      ClimateControl.modify environment_vars.merge('GMAIL_FROM' => email) do
        Dromelib.init!
        assert Dromelib::GMail.valid_from?
      end
    end

    [nil, '', 'wadus', '@wadus', 'wadus@', 'wadus@es'].each do |invalid_from|
      it "should be false for '#{invalid_from || '<nil>'}'" do
        ClimateControl.modify environment_vars.merge('GMAIL_FROM' => invalid_from) do
          Dromelib.init!
          refute Dromelib::GMail.valid_from?
          Dromelib.end!
        end
      end
    end
  end

  describe 'credentials required methods' do
    let(:address) {'valid@email.org'}
    let(:other_address) {'other@email.org'}
    let(:two_addresses) {[address, other_address].join(',')}
    let(:yaml_with_from) do
      yaml = yaml_content
      yaml['gmail']['from'] = address
      yaml
    end
    let(:yaml_with_two_froms) do
      yaml = yaml_content
      yaml['gmail']['from'] = two_addresses
      yaml
    end
    let(:gmail) { Minitest::Mock.new } # => Gmail.connect!(username, password)
    let(:inbox) { Minitest::Mock.new } # => gmail.inbox
    let(:email) { Minitest::Mock.new } # => inbox.find([...]).first
    let(:drome) { Minitest::Mock.new } # => Dromelib.drome
    let(:entry) { Minitest::Mock.new } # => Dromelib.drome.create_entry!('Wadus')

    after do
      gmail.verify
      inbox.verify
      email.verify
      drome.verify
    end

    [:unread_count, :import!].each do |method|
      it 'should raise MissingCredentialsError if not configured' do  
        YAML.stub(:load_file, {}) do
          ClimateControl.modify clean_environment do
            proc do
              Dromelib.init!
              refute Dromelib::GMail.configured?
              Dromelib::GMail.send method
            end.must_raise Dromelib::GMail::MissingCredentialsError
          end
        end
      end
    end

    describe '.unread_count' do
      let(:unread_from_A) { rand(42) }
      let(:unread_from_B) { rand(42) }

      it 'should return all unread emails count if .from is not set' do
        YAML.stub(:load_file, yaml_content) do
          ClimateControl.modify clean_environment do
            Dromelib.init!
            Gmail.stub(:connect!, gmail) do
              gmail.expect(:inbox, inbox)
              inbox.expect(:count, unread_from_A, [:unread])
              gmail.expect(:logout, true)
              Dromelib::GMail.unread_count.must_equal unread_from_A
            end
          end
        end
      end

      it 'should return the unread emails count from the specified address' do
        YAML.stub(:load_file, yaml_with_from) do
          ClimateControl.modify clean_environment do
            Dromelib.init!
            Gmail.stub(:connect!, gmail) do
              gmail.expect(:inbox, inbox)
              inbox.expect(:count, unread_from_A, [:unread, {from: address}])
              gmail.expect(:logout, true)
              Dromelib::GMail.unread_count.must_equal unread_from_A
            end
          end
        end
      end

      it 'should return the sum of unread emails from each address' do
        YAML.stub(:load_file, yaml_with_two_froms) do
          ClimateControl.modify clean_environment do
            Dromelib.init!
            Gmail.stub(:connect!, gmail) do
              gmail.expect(:inbox, inbox)
              inbox.expect(:count, unread_from_A, [:unread, {from: address}])
              gmail.expect(:inbox, inbox)
              inbox.expect(:count, unread_from_B, [:unread, {from: other_address}])
              gmail.expect(:logout, true)
              Dromelib::GMail.unread_count.must_equal unread_from_A + unread_from_B
            end
          end
        end
      end
    end

    describe '"from" required methods' do
      let(:subject) { 'drome Entry example' }
  
      %i(
        each_unread_email
        show_unread
        import!
      ).each do |method|
        describe ".#{method}" do
          it 'should raise MissingFromError if "from" is not valid' do  
            YAML.stub(:load_file, {}) do
              ClimateControl.modify environment_vars.merge('GMAIL_FROM' => 'invalid@email') do
                proc do
                  Dromelib.init!
                  Dromelib::GMail.send method
                end.must_raise Dromelib::GMail::MissingFromError
              end
            end
          end
        end
      end
    
      describe '.import!' do
        it 'should call its .read! method after reading an email' do
          YAML.stub(:load_file, yaml_with_from) do
            ClimateControl.modify clean_environment do
              Dromelib.init!
              Gmail.stub(:connect!, gmail) do
                Dromelib.stub(:drome, drome) do
                  gmail.expect(:inbox, inbox)
                  inbox.expect(:find, [email], [:unread, {from: address}])
                  email.expect(:subject, subject)
                  email.expect(:attachments, [])
  
                  drome.expect(:create_entry!, entry, [subject])
  
                  email.expect(:read!, false)
                  gmail.expect(:logout, true)
  
                  Dromelib::GMail.import!
                end
              end
            end
          end
        end
      end
    end
  end
end
