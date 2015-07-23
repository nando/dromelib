# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../spec_helper'

describe Dromelib::GMail do
  let(:clean_environment) {
    {
      GMAIL_USERNAME: nil,
      GMAIL_PASSWORD: nil,
      GMAIL_FROM: nil,
      GMAIL_PREFIX: nil
    }
  }

  let(:environment_vars) {
    {
      GMAIL_USERNAME: 'fernan.dogs',
      GMAIL_PASSWORD: 'guau!!! guau!!!',
      GMAIL_FROM: 'carer@doglovers.com',
      GMAIL_PREFIX: 'DROMO'
    }
  }

  let(:yaml) {
    Dromelib::Minitest.sections_hash
    #{
    #  'gmail' => {
    #    'username' => 'colgado',
    #    'password' => 'barking!',
    #  }
    #}
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

  describe '.username & .password singleton methods' do
    after do
      Dromelib.end!
    end

    it 'should return its values in the .dromelib.yml if not in the environment' do
      ClimateControl.modify clean_environment do
        YAML.stub(:load_file, yaml) do
          Dromelib.init!
          Dromelib::Config.stub(:gmail, OpenStruct.new(yaml['gmail'])) do
            Dromelib::GMail.username.must_equal yaml['gmail']['username']
            Dromelib::GMail.password.must_equal yaml['gmail']['password']
          end
        end
      end
    end
  
    it 'should check first the environment variables' do
      ClimateControl.modify environment_vars do
        Dromelib.init!
        Dromelib::GMail.username.must_equal environment_vars[:GMAIL_USERNAME]
        Dromelib::GMail.password.must_equal environment_vars[:GMAIL_PASSWORD]
      end
    end
  end

  describe '.from singleton method' do
    it 'should return the email in GMAIL_FROM env. var. if defined' do
      skip
      ClimateControl.modify environment_vars do
        Dromelib::GMail.from.must_equal environment_vars[:GMAIL_FROM]
      end
    end

    it 'should read the Config value if no GMAIL_FROM env. var.' do
      skip
      YAML.stub(:load_file, yaml) do
        Dromelib::Config.load_yaml!
        Dromelib::Config.stub(:gmail, OpenStruct.new(yaml['gmail'])) do
          Dromelib::Config.load_yaml!
          Dromelib::GMail.from.must_equal yaml['gmail']['from']
        end
      end
    end
  end

  describe '.configured? singleton method' do
    it 'should be true if we have .username & .password (.from is optional)' do
      skip
      YAML.stub(:load_file, yaml) do
        Dromelib::Config.load_yaml!
        ClimateControl.modify environment_vars.merge({GMAIL_FROM: nil}) do
          assert Dromelib::GMail.configured?,
                 '.username and .password should be enough to be configured'
        end
      end
    end
 
    it 'should not be .configured? if we do not have the username' do
      skip
      yaml_content = yaml
      yaml_content['gmail']['username'] = nil
      YAML.stub(:load_file, yaml_content) do
        Dromelib::Config.load_yaml!
        ClimateControl.modify environment_vars.merge({GMAIL_USERNAME: nil}) do
          Dromelib::Config.stub(:gmail, OpenStruct.new({})) do
            refute Dromelib::GMail.configured?
          end
        end
      end
    end
 
    it 'should not be .configured? if GMAIL_USERNAME is empty' do
      skip
      yaml_content = yaml
      yaml_content['gmail']['username'] = nil
      YAML.stub(:load_file, yaml_content) do
        Dromelib::Config.load_yaml!
        ClimateControl.modify environment_vars.merge({GMAIL_USERNAME: ''}) do
          refute Dromelib::GMail.configured?
        end
      end
    end
  
    it 'should not be configured if GMAIL_PASSWORD does not exist' do
      skip
      yaml_content = yaml
      yaml_content['gmail']['password'] = nil
      YAML.stub(:load_file, yaml_content) do
        Dromelib::Config.load_yaml!
        Dromelib::Config.stub(:gmail, OpenStruct.new({password: nil})) do
          ClimateControl.modify environment_vars.merge({GMAIL_PASSWORD: nil}) do
            refute Dromelib::GMail.configured?
          end
        end
      end
    end
  
    it 'should not be configured if GMAIL_PASSWORD is empty' do
      skip
      yaml_content = yaml
      yaml_content['gmail']['password'] = nil
      YAML.stub(:load_file, yaml_content) do
        Dromelib::Config.load_yaml!
        ClimateControl.modify environment_vars.merge({GMAIL_PASSWORD: ''}) do
          refute Dromelib::GMail.configured?
        end
      end
    end
  end

  describe '.subject_prefix' do
    it 'should return the GMAIL_PREFIX env. var.' do
      skip
      ClimateControl.modify environment_vars do
        Dromelib::GMail.subject_prefix.must_equal environment_vars[:GMAIL_PREFIX]
      end
    end

    it 'should return the string we have in .dromelib.yml (no GMAIL_PREFIX)' do
      skip
      yaml_content = yaml
      yaml_content['gmail']['username'] = nil
      YAML.stub(:load_file, yaml_content) do
        Dromelib::Config.load_yaml!
        prefix = 'dromo'
        Dromelib::Config.stub(:gmail, OpenStruct.new({subject_prefix: prefix})) do
          Dromelib::GMail.subject_prefix.must_equal prefix
        end
      end
    end
  end

  describe '.unread_count' do
    it 'should raise MissingCredentialsError if not configured' do  
      skip
      yaml_content = yaml
      yaml_content['gmail']['username'] = nil
      YAML.stub(:load_file, yaml_content) do
        Dromelib::Config.load_yaml!
        ClimateControl.modify environment_vars.merge({GMAIL_PASSWORD: nil}) do
          proc {
            Dromelib::Config.stub(:gmail, OpenStruct.new({password: nil})) do
              Dromelib::GMail.unread_count
            end
          }.must_raise Dromelib::GMail::MissingCredentialsError
        end
      end
    end

    it 'should return all unread emails count if .from is not set' do
      skip
      YAML.stub(:load_file, yaml) do
        Dromelib::Config.load_yaml!
        ClimateControl.modify environment_vars.merge({GMAIL_FROM: nil}) do
          Dromelib::Config.stub(:gmail, OpenStruct.new({from: nil})) do
            unread_count = rand(9999)
            gmail = Minitest::Mock.new
            inbox = Minitest::Mock.new
            Gmail.stub(:connect!, gmail) do
              gmail.expect(:inbox, inbox)
              inbox.expect(:count, unread_count, [:unread, {from: nil}])
              gmail.expect(:logout, true)
              Dromelib::GMail.unread_count.must_equal unread_count
            end
            gmail.verify
            inbox.verify
          end
        end
      end
    end
  end

  describe '.import!' do
    it 'should raise MissingFromError if "from" has no value' do  
      skip
      yaml_content = yaml
      yaml_content['gmail']['from'] = nil
      YAML.stub(:load_file, yaml_content) do
        Dromelib::Config.load_yaml!
        # Let's check some common invalid values...
        [nil, '', 'wadus', '@wadus', 'wadus@'].each do |invalid_from|
          proc {
            ClimateControl.modify environment_vars.merge({GMAIL_FROM: invalid_from}) do
              Dromelib::Config.stub(:gmail, OpenStruct.new({from: invalid_from})) do
                Dromelib::GMail.import!
              end
            end
          }.must_raise Dromelib::GMail::MissingFromError
        end
      end
    end
  end
end
