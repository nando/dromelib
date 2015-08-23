# Copyright 2015 The Cocktail Experience, S.L.
module Dromelib
  class DromeNotFoundError < ArgumentError; end

  # A place where any entry is welcome.
  class Drome
    class EntryExistsError < ArgumentError; end
    attr_reader :name

    def initialize(name = :docudrome)
      @name = name.to_s.downcase.to_sym
      _open
    end

    def self.open(name)
      new name
    end

    def self.local_config_file(name)
      "./config/dromes/#{name}.yml"
    end

    def self.gem_config_file(name)
      File.dirname(__FILE__) + "/../../config/dromes/#{name}.yml"
    end

    def entries
      @entries ||= (File.exist?(entries_json) ? _read_json : {})
    end

    def create_entry!(raw_entry)
      auido = raw_entry.to_sym
      fail(EntryExistsError, raw_entry) if entries[auido]
      @entries[auido] = Time.now.utc
      File.open(entries_json, 'w') do |file|
        file.write JSON.pretty_generate(@entries)
      end
      Dromelib::Entry.new(drome: self, auido: auido)
    end

    def entries_json
      "data/public/#{name}/entries.json"
    end

    private

    def _open
      config_file = _config_filepath
      fail(DromeNotFoundError, @name) unless File.exist?(config_file)
      YAML.load_file(config_file).each do |key, value|
        (class << self; self; end).class_eval do
          define_method key do
            value
          end
        end 
      end
    end

    def _config_filepath
      localfile = Drome.local_config_file(@name)
      if File.exist?(localfile)
        localfile
      else
        Drome.gem_config_file(@name)
      end
    end

    def _read_json
      JSON.parse(File.read(entries_json), symbolize_names: true)
    end
  end
end
