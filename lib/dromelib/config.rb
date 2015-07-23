# Copyright 2015 The Cocktail Experience, S.L.
require 'yaml'
require 'ostruct'
require_relative '../dromelib'

module Dromelib
  module Config
    extend self

    # .load_yaml! defines a method for each .dromelib.yml's section that returns its
    # content into a memoized OpenStruct.
    #
    # Manually it'd be:
    #   def environment_vars
    #      @@gmail ||= OpenStruct.new(yaml['gmail'])
    #   end
    #
    # And metaprogramming using the real .dromelib.yml keys:
    def load_yaml!
      @@yaml = nil
      yaml.each do |key, value|
        instance_eval {
          instance_variable_set "@#{key}", OpenStruct.new(value)
          define_method key do
            instance_variable_get "@#{key}"
          end
        }
      end
    end

    # Method to simplify things testing memoization
    def remove_yaml!
      yaml.each do |key, value|
        instance_eval {
          remove_instance_variable "@#{key}"
          undef_method key
        }
      end
      @@yaml = nil
    end

    def yaml
      return @@yaml unless @@yaml.nil?
      gem_yaml = YAML.load_file(File.dirname(__FILE__) + '/../../.dromelib.yml')
      lokal = local_yaml
      gem_yaml.each_key do |key|
        gem_yaml[key] ||= {}
        if lokal[key]
          gem_yaml[key].merge! lokal[key]
        end
      end
      @@yaml = gem_yaml
    rescue Errno::ENOENT
      {}
    end

    private

    def local_yaml
      YAML.load_file('.dromelib.yml')
    rescue Errno::ENOENT
      {}
    end
  end
end
