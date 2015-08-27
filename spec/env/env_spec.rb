# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../spec_helper'

describe Dromelib::Env do
  after do
    Dromelib.end!
  end

  let(:clean_environment) do
    {
      STREAM_ACTOR: nil,
      ACTIVITYSTREAM_ACTOR: nil
    }
  end

  let(:default_name) do
    {
      stream_actor: 'STREAM_ACTOR'
    }
  end

  let(:custom_name) do
    {
      stream_actor: 'CUSTOM_ACTOR'
    }
  end

  let(:environment_values) do
    {
      STREAM_ACTOR: 'colgado',
      CUSTOM_ACTOR: 'colgado_es'
    }
  end

  let(:yaml_content) do
    {
      'environment_vars' => {
        'stream_actor' => 'CUSTOM_ACTOR'
      }
    }
  end

  let(:actor) { 'Leonardo' }

  describe '::name_for' do
    it 'should use the default name on a clean environment' do
      Dromelib.init!
      ClimateControl.modify clean_environment do
        _(Dromelib::Env.name_for(:stream_actor)).must_equal default_name[:stream_actor]
      end
    end

    it 'should use the custom ENV var. name if .dromelib.yml says so' do
      YAML.stub(:load_file, yaml_content) do
        Dromelib.init!
        ClimateControl.modify environment_values do
          _(Dromelib::Env.name_for(:stream_actor)).must_equal custom_name[:stream_actor]
        end
      end
    end
  end

  describe '::value_for' do
    it 'should read the value of the default ENV var. on a clean environment' do
      Dromelib.init!
      ClimateControl.modify clean_environment.merge(environment_values) do
        _(Dromelib::Env.value_for(:stream_actor)).must_equal environment_values[:STREAM_ACTOR]
      end
    end

    it 'should read the value of the custom ENV variable if we want that' do
      YAML.stub(:load_file, yaml_content) do
        Dromelib.init!
        ClimateControl.modify clean_environment.merge(environment_values) do
          _(Dromelib::Env.value_for(:stream_actor)).must_equal environment_values[:CUSTOM_ACTOR]
        end
      end
    end
  end

  describe '::set_value_for' do
    it 'should set the value of the default ENV variable' do
      Dromelib.init!
      ClimateControl.modify clean_environment.merge(environment_values) do
        Dromelib::Env.set_value_for :stream_actor, actor
        _(ENV[default_name[:stream_actor]]).must_equal actor
      end
    end

    it 'should set the value of our custom ENV variable' do
      YAML.stub(:load_file, yaml_content) do
        Dromelib.init!
        ClimateControl.modify clean_environment.merge(environment_values) do
          Dromelib::Env.set_value_for :stream_actor, actor
          _(ENV[custom_name[:stream_actor]]).must_equal actor
        end
      end
    end
  end
end
