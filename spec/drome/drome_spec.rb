# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../spec_helper'

describe Dromelib::Drome do
  let(:dromename) { :exampledrome }
  let(:default_drome) { Dromelib::Drome.new }
  let(:yaml_content) do
    {
      drome_name: 'Drome of Wadus',
      entry_name: 'Wadez'
    }
  end

  describe '.new' do
    it 'should open the :docudrome by default' do
      _(default_drome.name).must_equal Dromelib::Drome.open(:docudrome).name
    end
  end

  describe '.open(dromename)' do
    it 'should raise an exception dromename does not exists in config/dromes' do
      proc do
        Dromelib::Drome.open(dromename)
      end.must_raise Dromelib::DromeNotFoundError
    end

    it 'should load the config yaml defining a method for each section' do
      File.stub(:exist?, true) do
        YAML.stub(:load_file, yaml_content) do
          drome = Dromelib::Drome.open(dromename)
          _(drome.drome_name).must_equal yaml_content[:drome_name]
          _(drome.entry_name).must_equal yaml_content[:entry_name]
        end
      end
    end

    it 'should open the gem config file if not present locally' do
      skip # SKIPPED: .stub use with Mock syntax in mind :(
      # gem_filepath = Dromelib::Drome.gem_config_file(dromename)
      # File.stub(:exist?, true, gem_filepath) do
      File.stub(:exist?, true) do
        # YAML.stub(:load_file, yaml_content, gem_filepath) do
        YAML.stub(:load_file, yaml_content) do
          drome = Dromelib::Drome.open(dromename)
          _(drome.drome_name).must_equal yaml_content[:drome_name]
        end
      end
    end

    it 'should open the local config file if it is in config/dromes' do
      skip # SKIPPED: .stub use with Mock syntax in mind :(
      # local_filepath = Dromelib::Drome.local_config_file(dromename)
      # File.stub(:exist?, true, local_filepath) do
      File.stub(:exist?, true) do
        # YAML.stub(:load_file, yaml_content, local_filepath) do
        YAML.stub(:load_file, yaml_content) do
          drome = Dromelib::Drome.open(dromename)
          _(drome.drome_name).must_equal yaml_content[:drome_name]
        end
      end
    end

    it 'should keep the name of the drome as symbol' do
      _(Dromelib::Drome.open('docudrome').name).must_equal :docudrome
    end
  end

  describe '#create_entry!' do
    it 'should return an Entry instance with the right drome inside' do
      JSON.stub(:parse, {}) do
        entry = default_drome.create_entry!('SemVer')
        entry.must_be_kind_of Dromelib::Entry
        entry.drome.must_equal default_drome
      end
    end

    it 'should raise EntryExistsError if that name/auido is already present' do
      JSON.stub(:parse, {}) do
        proc do
          default_drome.create_entry!('Ruby')
          default_drome.create_entry!('Ruby')
        end.must_raise Dromelib::Drome::EntryExistsError
      end
    end

    it 'should write the entries file with the new entry included' do
      skip
      entries_file = Minitest::Mock.new
      entries_file.expect(:write, 42, [String])
      File.stub(:open, true, entries_file) do
        default_drome.create_entry!('SemVer')
      end
      entries_file.verify
    end
  end
end
