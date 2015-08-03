# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../spec_helper'

describe Dromelib::GMail do
  after do
    Dromelib.end!
  end

  let(:clean_environment) {
    {
      'GMAIL_USERNAME' => nil,
      'GMAIL_PASSWORD' => nil,
      'GMAIL_FROM' => nil,
      'GMAIL_SUBJECT_PREFIX' => nil
    }
  }

  let(:environment_vars) {
    {
      'GMAIL_USERNAME' => 'fernan.dogs',
      'GMAIL_PASSWORD' => 'guau!!! guau!!!'
    }
  }

  let(:yaml_content) {
    {
      'gmail' => {
        'username' => 'colgado',
        'password' => 'barking'
      }
    }
  }

  describe 'instance methods' do
    it 'should raise UninitializedError unless Dromelib.init! has been called first' do
      Dromelib::GMail.instance_methods.each do |method| 
        proc {
          Dromelib::GMail.send method
        }.must_raise Dromelib::UninitializedError
      end
    end
  end

  %w{
    username
    password
    from
    subject_prefix
  }.each do |method|
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
          Dromelib.init!
          Dromelib::GMail.send(method).must_equal environment_vars["GMAIL_#{method.upcase}"]
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
 
    %w{
      username
      password
    }.each do |required_param|
      it "should be false if the #{required_param} is missing" do
        yaml = yaml_content
        yaml['gmail'][required_param] = nil
        env = environment_vars.merge({"GMAIL_#{required_param.upcase}" => nil})
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
        env = environment_vars.merge({"GMAIL_#{required_param.upcase}" => ''})
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
    it 'should be true for a valid email' do
      email = 'valid@email.org'

          ClimateControl.modify environment_vars.merge({'GMAIL_FROM' => email}) do
            Dromelib.init!
            assert Dromelib::GMail.valid_from?
          end

    end

    [nil, '', 'wadus', '@wadus', 'wadus@', 'wadus@es'].each do |invalid_from|
      it "should be false for '#{invalid_from||'<nil>'}'" do
        ClimateControl.modify environment_vars.merge({'GMAIL_FROM' => invalid_from}) do
          Dromelib.init!
          refute Dromelib::GMail.valid_from?
          Dromelib.end!
        end
      end
    end
  end

  describe 'credentials required methods' do
    [:unread_count, :import!].each do |method|
      it 'should raise MissingCredentialsError if not configured' do  
        YAML.stub(:load_file, {}) do
          ClimateControl.modify clean_environment do
            proc {
              Dromelib.init!
              refute Dromelib::GMail.configured?
              Dromelib::GMail.send method
            }.must_raise Dromelib::GMail::MissingCredentialsError
          end
        end
      end
    end

    describe '.unread_count' do
      it 'should return all unread emails count if .from is not set' do
        unread_count = rand(9999)
        gmail = Minitest::Mock.new
        inbox = Minitest::Mock.new
  
        YAML.stub(:load_file, yaml_content) do
          Dromelib.init!
          Gmail.stub(:connect!, gmail) do
            gmail.expect(:inbox, inbox)
            inbox.expect(:count, unread_count, [:unread, {from: nil}])
            gmail.expect(:logout, true)
            Dromelib::GMail.unread_count.must_equal unread_count
          end
  
          Dromelib::GMail.unread_count
  
          gmail.verify
          inbox.verify
        end
      end
    end
  
    describe '.import!' do
      it 'should raise MissingFromError if "from" is not valid' do  
        YAML.stub(:load_file, {}) do
          ClimateControl.modify environment_vars.merge({GMAIL_FROM: 'invalid@email'}) do
            proc {
              Dromelib.end! if Dromelib.initialized?
              Dromelib.init!
              Dromelib::GMail.import!
            }.must_raise Dromelib::GMail::MissingFromError
          end
        end
      end
    end
  end
end
