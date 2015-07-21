require_relative '../spec_helper'

Dromelib::Minitest.add_config_section 'gmail', {
  'username' => 'fernando.gs',
  'password' => 'human-barking!',
  'from' => 'myselphone@gmail.com'
}

describe Dromelib::GMail do
  let(:environment_vars) {
    {
      DROMELIB_GMAIL_USERNAME: 'fernan.dogs',
      DROMELIB_GMAIL_PASSWORD: 'guau!!! guau!!!',
      DROMELIB_GMAIL_FROM: 'carer@doglovers.com',
      DROMELIB_GMAIL_PREFIX: 'DROMO'
    }
  }

  let(:yaml) {
    Dromelib::Minitest.yaml_content
  }

  describe '.username & .password singleton methods' do
    it 'should return the .dromelib.yml' do

    YAML.stub(:load_file, yaml) do
      Dromelib::Config.load_yaml!

      Dromelib::Config.stub(:gmail, OpenStruct.new(yaml['gmail'])) do
        Dromelib::GMail.username.must_equal yaml['gmail']['username']
        Dromelib::GMail.password.must_equal yaml['gmail']['password']
      end

    end


    end
  
    it 'should check first the environment variables' do
      ClimateControl.modify environment_vars do
        Dromelib::GMail.username.must_equal environment_vars[:DROMELIB_GMAIL_USERNAME]
        Dromelib::GMail.password.must_equal environment_vars[:DROMELIB_GMAIL_PASSWORD]
      end
    end
  end

  describe '.from singleton method' do
    it 'should return the email in DROMELIB_GMAIL_FROM env. var. if defined' do
      ClimateControl.modify environment_vars do
        Dromelib::GMail.from.must_equal environment_vars[:DROMELIB_GMAIL_FROM]
      end
    end

    it 'should read the Config value if no DROMELIB_GMAIL_FROM env. var.' do
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
      YAML.stub(:load_file, yaml) do
        Dromelib::Config.load_yaml!
        ClimateControl.modify environment_vars.merge({DROMELIB_GMAIL_FROM: nil}) do
          assert Dromelib::GMail.configured?,
                 '.username and .password should be enough to be configured'
        end
      end
    end
  
    it 'should not be .configured? if we do not have the username' do
      yaml_content = yaml
      yaml_content['gmail']['username'] = nil
      YAML.stub(:load_file, yaml_content) do
        Dromelib::Config.load_yaml!
        ClimateControl.modify environment_vars.merge({DROMELIB_GMAIL_USERNAME: nil}) do
          Dromelib::Config.stub(:gmail, OpenStruct.new({})) do
             refute Dromelib::GMail.configured?
          end
        end
      end
    end
  
    it 'should not be .configured? if DROMELIB_GMAIL_USERNAME is empty' do
      yaml_content = yaml
      yaml_content['gmail']['username'] = nil
      YAML.stub(:load_file, yaml_content) do
        Dromelib::Config.load_yaml!
        ClimateControl.modify environment_vars.merge({DROMELIB_GMAIL_USERNAME: ''}) do
          refute Dromelib::GMail.configured?
        end
      end
    end
  
    it 'should not be configured if DROMELIB_GMAIL_PASSWORD does not exist' do
      yaml_content = yaml
      yaml_content['gmail']['password'] = nil
      YAML.stub(:load_file, yaml_content) do
        Dromelib::Config.load_yaml!
        Dromelib::Config.stub(:gmail, OpenStruct.new({password: nil})) do
          ClimateControl.modify environment_vars.merge({DROMELIB_GMAIL_PASSWORD: nil}) do
            refute Dromelib::GMail.configured?
          end
        end
      end
    end
  
    it 'should not be configured if DROMELIB_GMAIL_PASSWORD is empty' do
      yaml_content = yaml
      yaml_content['gmail']['password'] = nil
      YAML.stub(:load_file, yaml_content) do
        Dromelib::Config.load_yaml!
        ClimateControl.modify environment_vars.merge({DROMELIB_GMAIL_PASSWORD: ''}) do
          refute Dromelib::GMail.configured?
        end
      end
    end
  end

  describe '.subject_prefix' do
    it 'should return the DROMELIB_GMAIL_PREFIX env. var.' do
      ClimateControl.modify environment_vars do
        Dromelib::GMail.subject_prefix.must_equal environment_vars[:DROMELIB_GMAIL_PREFIX]
      end
    end

    it 'should return the string we have in .dromelib.yml (no DROMELIB_GMAIL_PREFIX)' do
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
      yaml_content = yaml
      yaml_content['gmail']['username'] = nil
      YAML.stub(:load_file, yaml_content) do
        Dromelib::Config.load_yaml!
        ClimateControl.modify environment_vars.merge({DROMELIB_GMAIL_PASSWORD: nil}) do
          proc {
            Dromelib::Config.stub(:gmail, OpenStruct.new({password: nil})) do
              Dromelib::GMail.unread_count
            end
          }.must_raise Dromelib::GMail::MissingCredentialsError
        end
      end
    end

    it 'should return all unread emails count if .from is not set' do
      YAML.stub(:load_file, yaml) do
        Dromelib::Config.load_yaml!
        ClimateControl.modify environment_vars.merge({DROMELIB_GMAIL_FROM: nil}) do
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
end
