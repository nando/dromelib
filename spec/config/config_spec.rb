# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../spec_helper'

describe Dromelib::Config do
  after do
    Dromelib.end! # Needed to clean the memoized stuff
  end

  # Partial content of the initial .dromelib.yml bundled with the gem:
  #     environment_vars:
  #       stream_actor: STREAM_ACTOR
  #     [...]
  let(:gem_yaml) do
    YAML.load_file(File.dirname(__FILE__) + '/../../.dromelib.yml')
  end

  let(:stubbed_yaml) do
    {
      'app' => {
        'name' => 'DromeOnRails'
      },
      'environment_vars' => {
        'stream_actor' => 'CUSTOM_ENV_VAR',
        'not_in_gem' => 'FOOBAR'
      },
      'not_in_gem' => {
        'values' => 'IGNORED'
      }
    }
  end

  describe 'the gem .dromelib.yml' do
    it 'should have only the sections defined by the class' do
      gem_yaml.each_key do |yaml_section|
        _(Dromelib::Config.sections).must_include yaml_section
      end
    end
  end

  describe '.gem_yaml class method' do
    it 'should return a hash whose keys are the sections defined by the class' do 
      _(Dromelib::Config.gem_yaml.keys.sort).must_equal Dromelib::Config.sections.sort
    end

    it 'should return the gem .dromelib.yml contents' do
      gem_yaml.each do |section, config|
        _(Dromelib::Config.gem_yaml[section]).must_equal config
      end
    end
  end

  describe '.local_yaml class method' do
    it 'should return only the local .dromelib.yml sections defined by the class' do
      YAML.stub(:load_file, stubbed_yaml) do
        stubbed_yaml.each do |section, config|
          if Dromelib::Config.sections.include? section
            _(Dromelib::Config.local_yaml.keys).must_include section
          else
            _(Dromelib::Config.local_yaml.keys).wont_include section
          end
        end
      end
    end

    it 'should return the config values defined into the local .dromelib.yml' do
      YAML.stub(:load_file, stubbed_yaml) do
        Dromelib::Config.local_yaml.each do |section, config|
          _(config).must_equal stubbed_yaml[section]
        end
      end
    end
  end

  describe '.yaml' do
    it 'should have only the sections defined by the class' do
      YAML.stub(:load_file, stubbed_yaml) do
        _(Dromelib::Config.yaml.keys.sort).must_equal Dromelib::Config.sections.sort
      end
    end

    it '.local_yaml should overwrite .gem_yaml values' do
      YAML.stub(:load_file, stubbed_yaml) do
        Dromelib::Config.yaml.each do |section, config|
          if Dromelib::Config.local_yaml.keys.include?(section)
            _(config).must_equal stubbed_yaml[section]
          else
            _(config).must_equal Dromelib::Config.gem_yaml[section]
          end
        end
      end
    end
  end

  describe '.load_yaml!' do
    it 'should define a method for each section returning an OpenStruct w/ its config' do
      YAML.stub(:load_file, stubbed_yaml) do
        Dromelib::Config.load_yaml!
        Dromelib::Config.yaml.each_key do |section|
          os = Dromelib::Config.send(section)
          _(os).must_be_kind_of OpenStruct
          Dromelib::Config.yaml[section].each do |key, value|
            _(os.send(key)).must_equal value
          end
        end
      end
    end
  end
end
