# Copyright 2015 The Cocktail Experience, S.L.
require 'yaml'
require 'ostruct'
require_relative '../dromelib'

module Dromelib
  module Config
    extend self

    attr_reader :sections, :gem_yaml

    @sections = %w{
      app
      environment_vars
      gmail
    }

    @gem_yaml = begin
      @sections.inject({}) do |hash, section|
        hash[section] = {}
        hash
      end.merge \
        YAML.load_file(File.dirname(__FILE__) + '/../../.dromelib.yml')
    end

    def local_yaml
      @local_yaml ||= YAML.load_file('.dromelib.yml').select {|k, v| @sections.include? k}
    rescue Errno::ENOENT
      {}
    end

    # .load_yaml! defines a method for each .dromelib.yml's section that returns its
    # content into a memoized OpenStruct.
    def load_yaml!
      yaml.each do |key, value|
        instance_variable_set :"@#{key}", OpenStruct.new(value)
        define_method key do
          instance_variable_get :"@#{key}"
        end
      end
    end

    # Method to simplify things testing memoization
    def remove_yaml!
      if instance_variables.include?(:@yaml)
        @yaml.each do |key, value|
          if respond_to?(key)
            remove_instance_variable :"@#{key}"
            undef_method key
          end
        end
        remove_instance_variable :@yaml
      end
      remove_instance_variable :@local_yaml if instance_variables.include?(:@local_yaml)
    end

    def yaml
      @yaml ||= gem_yaml.merge(local_yaml)
    end
  end
end
