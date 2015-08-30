# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../spec_helper'

describe Dromelib::Neo4j do
  after do
    Dromelib.end!
  end

  let(:clean_environment) do
    {
      'NEO4J_HOST' => nil,
      'NEO4J_PORT' => nil,
      'NEO4J_USERNAME' => nil,
      'NEO4J_PASSWORD' => nil
    }
  end

  let(:environment_vars) do
    {
      'NEO4J_HOST' => 'environment.srv',
      'NEO4J_PORT' => '11111',
      'NEO4J_USERNAME' => 'env_user',
      'NEO4J_PASSWORD' => 'env_pass'
    }
  end
  let(:env_rest_url) { 'http://env_user:env_pass@environment.srv:11111' }

  let(:yaml_content) do
    {
      'neo4j' => {
        'host' => 'dromelib.yml', 
        'port' => '22222', 
        'username' => 'yml_user',
        'password' => 'yml_pass'
      }
    }
  end
  let(:yml_rest_url) { 'http://yml_user:yml_pass@dromelib.yml:22222' }

  %w(
    host
    port
    username
    password
  ).each do |method|
    describe "::#{method} singleton method" do
      it 'should raise UninitializedError unless Dromelib.init! has been called first' do
        proc do
          Dromelib::Neo4j.send method
        end.must_raise Dromelib::UninitializedError
      end

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

  describe '::configured? (only host & port are required)' do
    it 'should work using ENV variables' do
      YAML.stub(:load_file, Dromelib::Config.gem_yaml) do
        ClimateControl.modify environment_vars do
          Dromelib.init!
          _(Dromelib::Neo4j).must_be :configured?
        end
      end
    end
 
    it 'should work using our local .dromelib.yml' do
      YAML.stub(:load_file, yaml_content) do
        ClimateControl.modify clean_environment do
          Dromelib.init!
          _(Dromelib::Neo4j).must_be :configured?
        end
      end
    end
 
    %w(
      host
      port
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

  describe '::rest_url' do
    let(:rest_url) { 'http://dromelib.yml:22222' }

    it 'should work using ENV variables' do
      YAML.stub(:load_file, Dromelib::Config.gem_yaml) do
        ClimateControl.modify environment_vars do
          Dromelib.init!
          _(Dromelib::Neo4j.rest_url).must_equal env_rest_url
        end
      end
    end
 
    it 'should work using our local .dromelib.yml' do
      YAML.stub(:load_file, yaml_content) do
        ClimateControl.modify clean_environment do
          Dromelib.init!
          _(Dromelib::Neo4j.rest_url).must_equal yml_rest_url
        end
      end
    end
 
    %w(
      username
      password
    ).each do |config_key|
      describe "without #{config_key} credential value" do
        it 'should build the right (short) URI' do
          yaml = yaml_content
          yaml['neo4j'][config_key] = nil
          YAML.stub(:load_file, yaml) do
            ClimateControl.modify clean_environment do
              Dromelib.init!
              _(Dromelib::Neo4j.rest_url).must_equal rest_url
            end
          end
        end
      end
    end
  end

  describe '#klass' do
    let(:my_klass) { :AwesomeKlass }

    it 'should give us the class used to comunicate w/ the Neo4j server' do
      YAML.stub(:load_file, Dromelib::Config.gem_yaml) do
        ClimateControl.modify environment_vars do
          Dromelib.init!
          _(Dromelib::Neo4j.new.klass.class).must_equal Class
        end
      end
    end

    it 'should let us inject the klass thile creating the instance' do
      YAML.stub(:load_file, Dromelib::Config.gem_yaml) do
        ClimateControl.modify environment_vars do
          Dromelib.init!
          _(Dromelib::Neo4j.new(my_klass).klass).must_equal my_klass
        end
      end
    end
  end

  describe '#neo' do
    it 'should raise Neo4j::UnconfiguredError unless ::configured?' do
      proc do
        YAML.stub(:load_file, Dromelib::Config.gem_yaml) do
          ClimateControl.modify environment_vars do
            Dromelib::Neo4j.stub(:configured?, false) do
              Dromelib.init!
              Dromelib::Neo4j.new.neo
            end
          end
        end
      end.must_raise Dromelib::Neo4j::UnconfiguredError
    end
  end
end
