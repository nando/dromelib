require_relative '../spec_helper'

describe Dromelib::GMail do
  environment_vars = {
    DROMELIB_GMAIL_USERNAME: 'fernan.dogs',
    DROMELIB_GMAIL_PASSWORD: 'guau!!! guau!!!',
    DROMELIB_GMAIL_FROM: 'carer@doglovers.com',
    DROMELIB_GMAIL_PREFIX: 'DROMO'
  }

  yaml_content = {
    'gmail' => {
      'username' => 'fernando.gs',
      'password' => 'human-barking!',
      'from' => 'my.cellphone.email@gmail.com'
    }
  }

  it '.username & .password should return the .dromelib.yml' do
    YAML.stub(:load_file, yaml_content) do
      Dromelib::GMail.username.must_equal yaml_content['gmail']['username']
      Dromelib::GMail.password.must_equal yaml_content['gmail']['password']
    end
  end

  it '.username & .password should check first the environment variables' do
    ClimateControl.modify environment_vars do
      Dromelib::GMail.username.must_equal environment_vars[:DROMELIB_GMAIL_USERNAME]
      Dromelib::GMail.password.must_equal environment_vars[:DROMELIB_GMAIL_PASSWORD]
    end
  end

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

  it 'should be .configured? if we have .username & .password (.from is optional)' do
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

  it '.subject_prefix should return the string we have in .dromelib.yml' do
    prefix = 'dromo'
    YAML.stub(:load_file, {'gmail' => {'subject_prefix' => prefix}}) do
      Dromelib::GMail.subject_prefix.must_equal prefix
    end
  end

  it '.subject_prefix should return the DROMELIB_GMAIL_PREFIX env. var.' do
    ClimateControl.modify environment_vars do
      Dromelib::GMail.subject_prefix.must_equal environment_vars[:DROMELIB_GMAIL_PREFIX]
    end
  end

  describe '.unread_count' do
    it 'should raise MissingCredentialsError if not configured' do  
      skip 'still not able/ready to make this work (stub+exception) :('
      # Spec without stubbing (.dromelib.yml.example must be renamed):
      #
      # ClimateControl.modify environment_vars.merge({DROMELIB_GMAIL_PASSWORD: nil}) do
      #   proc {
      #     Dromelib::GMail.unread_count
      #   }.must_raise Dromelib::GMail::MissingCredentialsError
      # end
      #
      # Try to make the stub into the proc:
      # ClimateControl.modify environment_vars.merge({DROMELIB_GMAIL_PASSWORD: nil}) do
      #   proc {
      #     YAML.stub(:load_file, yaml_content) do
      #       Dromelib::GMail.unread_count
      #     end
      #   }.must_raise Dromelib::GMail::MissingCredentialsError
      # end
    end
  end
end
