# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../spec_helper'

describe Dromelib::Config do
  let(:yaml_content) {
    {}
  }

  it 'should define a method for each .dromelib.yml section (1st level key)' do
    skip
    YAML.stub(:load_file, yaml_content) do
      Dromelib::Config.load_yaml!
      assert Dromelib::Config.respond_to?(:app)
      assert Dromelib::Config.respond_to?(:environment_vars)
    end
  end

  describe '.yaml singleton method' do
    it 'should return the .dromelib.yml hash' do
      skip
      YAML.stub(:load_file, yaml_content) do
        Dromelib::Config.load_yaml!
        Dromelib::Config.yaml.must_equal yaml_content
      end
    end
  end

  describe 'each dinamically defined method' do
    it 'should return an OpenStruct w/ the keys&values defined in the yaml' do
      skip
      YAML.stub(:load_file, yaml_content) do
        Dromelib::Config.load_yaml!
        Dromelib::Config.app.class.must_equal OpenStruct
        Dromelib::Config.app.name.must_equal yaml_content['app']['name']
      end
    end
  end
end
