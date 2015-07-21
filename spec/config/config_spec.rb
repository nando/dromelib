require_relative '../spec_helper'

Dromelib::Minitest.add_config_section 'app', {
  'name' => %!Nando's RailsOnDrome!,
}  

Dromelib::Minitest.add_config_section 'environment_vars', {
  'neo4j_server' => 'NEO4J_SERVER',
  'neo4j_username' => 'NEO4J_USERNAME',
  'neo4j_password' => 'NEO4J_PASSWORD'
}

describe Dromelib::Config do
  let(:yaml_content) {
    Dromelib::Minitest.yaml_content
  }

  it 'should define a method for each .dromelib.yml section (1st level key)' do
    YAML.stub(:load_file, yaml_content) do
      Dromelib::Config.load_yaml!
      assert Dromelib::Config.respond_to?(:app)
      assert Dromelib::Config.respond_to?(:environment_vars)
    end
  end

  describe '.yaml singleton method' do
    it 'should return the .dromelib.yml hash' do
      YAML.stub(:load_file, yaml_content) do
        Dromelib::Config.load_yaml!
        Dromelib::Config.yaml.must_equal yaml_content
      end
    end
  end

  describe 'each dinamically defined method' do
    it 'should return an OpenStruct w/ the keys&values defined in the yaml' do
      YAML.stub(:load_file, yaml_content) do
        Dromelib::Config.load_yaml!
        Dromelib::Config.app.class.must_equal OpenStruct
        Dromelib::Config.app.name.must_equal yaml_content['app']['name']
      end
    end
  end
end
