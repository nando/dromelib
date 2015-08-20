# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../spec_helper'

describe Dromelib::Drome do
  let(:dromename) { :exampledrome }
  let(:default_drome) { Dromelib::Drome.new }
  let(:yaml_content) do
    {
      drome_name: 'Drome of Wadus'
    }
  end

  describe '.new' do
    it 'should open the :docudrome by default' do
      default_drome.name.must_equal Dromelib::Drome.open(:docudrome).name
    end
  end

  describe '.open(dromename)' do
    it 'should raise an exception dromename does not exists in config/dromes' do
      proc do
        Dromelib::Drome.open(dromename)
      end.must_raise Dromelib::DromeNotFoundError
    end

    it 'should open the gem config file if not present locally' do
      gem_filepath = Dromelib::Drome.gem_config_file(dromename)
      File.stub(:exist?, true, gem_filepath) do
        YAML.stub(:load_file, yaml_content, gem_filepath) do
          drome = Dromelib::Drome.open(dromename)
          drome.drome_name.must_equal yaml_content[:drome_name]
        end
      end
    end

    it 'should open the local config file if it is in config/dromes' do
      local_filepath = Dromelib::Drome.local_config_file(dromename)
      File.stub(:exist?, true, local_filepath) do
        YAML.stub(:load_file, yaml_content, local_filepath) do
          drome = Dromelib::Drome.open(dromename)
          drome.drome_name.must_equal yaml_content[:drome_name]
        end
      end
    end

    it 'should keep the name of the drome as symbol' do
      Dromelib::Drome.open('docudrome').name.must_equal :docudrome
    end
  end

  describe '#new_entry' do
    it 'should return an Entry instance with the right drome inside' do
      entry = default_drome.new_entry('SemVer')
      entry.must_be_kind_of Dromelib::Entry
      entry.drome.must_equal default_drome
    end
  end
end
