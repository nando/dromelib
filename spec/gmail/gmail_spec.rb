require_relative '../spec_helper'

describe Dromelib::GMail do
  let(:environment_vars) {
    {
      DROMELIB_GMAIL_USERNAME: 'fernan.dogs',
      DROMELIB_GMAIL_PASSWORD: 'guau!!! guau!!!',
      DROMELIB_GMAIL_FROM: 'carer@doglovers.com',
      DROMELIB_GMAIL_PREFIX: 'DROMO'
    }
  }

  let(:yaml_content) {
    {
      'gmail' => {
        'username' => 'fernando.gs',
        'password' => 'human-barking!',
        'from' => 'my.cellphone.email@gmail.com'
      }
    }
  }

  describe '.username & .password singleton methods' do
    it 'should return the .dromelib.yml' do
      YAML.stub(:load_file, yaml_content) do
        Dromelib::GMail.username.must_equal yaml_content['gmail']['username']
        Dromelib::GMail.password.must_equal yaml_content['gmail']['password']
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
    it '.from should return the email we have in .dromelib.yml' do
      YAML.stub(:load_file, yaml_content) do
        Dromelib::GMail.from.must_equal yaml_content['gmail']['from']
      end
    end

    it '.from should return the email in DROMELIB_GMAIL_FROM env. var. (has precedence)' do
      ClimateControl.modify environment_vars do
        Dromelib::GMail.from.must_equal environment_vars[:DROMELIB_GMAIL_FROM]
      end
    end
  end

  describe '.configured? singleton method' do
    it 'should be true if we have .username & .password (.from is optional)' do
      ClimateControl.modify environment_vars.merge({DROMELIB_GMAIL_FROM: nil}) do
        assert Dromelib::GMail.configured?,
               '.username and .password should be enough to be configured'
      end
    end
  
    it 'should not be .configured? if we do not have the username' do
      ClimateControl.modify environment_vars.merge({DROMELIB_GMAIL_USERNAME: nil}) do
        YAML.stub(:load_file, yaml_content.merge({'gmail' => {}})) do
          refute Dromelib::GMail.configured?
        end
      end
    end
  
    it 'should not be .configured? if DROMELIB_GMAIL_USERNAME is empty' do
      ClimateControl.modify environment_vars.merge({DROMELIB_GMAIL_USERNAME: ''}) do
        refute Dromelib::GMail.configured?
      end
    end
  
    it 'should not be configured if DROMELIB_GMAIL_PASSWORD does not exist' do
      YAML.stub(:load_file, yaml_content.merge({'gmail' => {'password' => nil}})) do
        ClimateControl.modify environment_vars.merge({DROMELIB_GMAIL_PASSWORD: nil}) do
          refute Dromelib::GMail.configured?
        end
      end
    end
  
    it 'should not be configured if DROMELIB_GMAIL_PASSWORD is empty' do
      ClimateControl.modify environment_vars.merge({DROMELIB_GMAIL_PASSWORD: ''}) do
        refute Dromelib::GMail.configured?
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
      prefix = 'dromo'
      YAML.stub(:load_file, {'gmail' => {'subject_prefix' => prefix}}) do
        Dromelib::GMail.subject_prefix.must_equal prefix
      end
    end
  end

  describe '.unread_count' do
    it 'should raise MissingCredentialsError if not configured' do  
      ClimateControl.modify environment_vars.merge({DROMELIB_GMAIL_PASSWORD: nil}) do
        proc {
          yaml = yaml_content
          yaml['gmail']['password'] = nil
          YAML.stub(:load_file, yaml) do
            Dromelib::GMail.unread_count
          end
        }.must_raise Dromelib::GMail::MissingCredentialsError
      end
    end
  end
end
