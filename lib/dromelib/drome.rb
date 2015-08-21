# Copyright 2015 The Cocktail Experience, S.L.
module Dromelib
  class DromeNotFoundError < ArgumentError; end

  # A place where any entry is welcome.
  class Drome
    class EntryExistsError < ArgumentError; end
    attr_reader :name

    def initialize(name = :docudrome)
      @name = name.to_s.downcase.to_sym
      open
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
      @entries ||= {}
    end

    def create_entry!(raw_entry)
      auido = raw_entry.to_sym
      fail EntryExistsError if entries[auido]
      @entries[auido] = Time.now.utc
      Dromelib::Entry.new(drome: self, auido: auido)
    end

    def method_missing(method, *args, &block)
      @yaml[method.to_sym] || super
    end

    private

    def open
      config_file = config_filepath
      fail(DromeNotFoundError, @name) unless File.exist?(config_file)
      @yaml = YAML.load_file(config_file)
    end

    def config_filepath
      localfile = Drome.local_config_file(@name)
      if File.exist?(localfile)
        localfile
      else
        Drome.gem_config_file(@name)
      end
    end
  end
end
