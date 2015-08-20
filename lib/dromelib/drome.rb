# Copyright 2015 The Cocktail Experience, S.L.
module Dromelib
  class DromeNotFoundError < ArgumentError; end

  # A place where any entry is welcome.
  class Drome
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

    def new_entry(auido)
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
