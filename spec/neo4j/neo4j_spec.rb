# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../spec_helper'

describe Dromelib::Neo4j do
  after do
    Dromelib.end!
  end

  let(:clean_environment) do
    {
      'NEO4J_SERVER' => nil,
      'NEO4J_USERNAME' => nil,
      'NEO4J_PASSWORD' => nil
    }
  end

  let(:environment_vars) do
    {
      'NEO4J_SERVER' => 'http://environment.srv:7474',
      'NEO4J_USERNAME' => 'env_user',
      'NEO4J_PASSWORD' => 'env_pass'
    }
  end

  let(:yaml_content) do
    {
      'neo4j' => {
        'server' => 'http://dromelib.yml:7474', 
        'username' => 'yml_user',
        'password' => 'yml_pass'
      }
    }
  end

  # Dromelib.init! call check in methods without params
  Dromelib::Neo4j.instance_methods.each do |method| 
    next if Dromelib::Neo4j.method(method).arity > 0
    describe "::#{method}" do
      it 'should raise UninitializedError unless Dromelib.init! has been called first' do
        proc do
          Dromelib::Neo4j.send method
        end.must_raise Dromelib::UninitializedError
      end
    end
  end

  %w(
    server
    username
    password
  ).each do |method|
    describe "::#{method} singleton method" do
      it 'should return its value in .dromelib.yml if not present in the environment' do
        ClimateControl.modify clean_environment do
          YAML.stub(:load_file, yaml_content) do
            Dromelib.init!
            _(Dromelib::Neo4j.send(method)).must_equal yaml_content['neo4j'][method]
          end
        end
      end

      it 'should check first the environment variable' do
        ClimateControl.modify environment_vars do
          YAML.stub(:load_file, {}) do
            Dromelib.init!
            _(Dromelib::Neo4j.send(method)).must_equal environment_vars["NEO4J_#{method.upcase}"]
          end
        end
      end
    end
  end

  describe '::configured? (only server is required)' do
    it 'should work using ENV variables' do
      YAML.stub(:load_file, Dromelib::Config.gem_yaml) do
        ClimateControl.modify environment_vars do
          Dromelib.init!
          _(Dromelib::Neo4j).must_be :configured?
        end
      end
    end
 
    it 'should work using out local .dromelib.yml' do
      YAML.stub(:load_file, yaml_content) do
        ClimateControl.modify clean_environment do
          Dromelib.init!
          _(Dromelib::Neo4j).must_be :configured?
        end
      end
    end
 
    %w(
      server
    ).each do |required_param|
      it "should be false if the #{required_param} is missing" do
        yaml = yaml_content
        yaml['neo4j'][required_param] = nil
        env = environment_vars.merge("NEO4J_#{required_param.upcase}" => nil)
        YAML.stub(:load_file, yaml) do
          ClimateControl.modify env do
            Dromelib.init!
            _(Dromelib::Neo4j).wont_be :configured?
          end
        end
      end
   
      it "should be false if the #{required_param} is an empty string" do
        yaml = yaml_content
        yaml_content['neo4j'][required_param] = ''
        env = environment_vars.merge("NEO4J_#{required_param.upcase}" => '')
        YAML.stub(:load_file, yaml) do
          ClimateControl.modify env do
            Dromelib.init!
            _(Dromelib::Neo4j).wont_be :configured?
          end
        end
      end
    end
  end
end
