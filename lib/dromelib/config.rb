# Copyright 2015 The Cocktail Experience, S.L.
require 'yaml'
require 'ostruct'
require_relative '../dromelib'

module Dromelib
  # Usage:
  #   * 1st- require the lib:
  #     > require './path/to/lib/dromelib'
  #
  #   * 2nd- load the .dromelib.yml in the local directory:
  #     > Dromelib::Config.load_yaml!
  #
  #   * 3rd- call/ruby-ask any config value:
  #     > Dromelib::Config.environment_vars.neo4j.password
  #
  #   * 4th- access to the full raw .dromelib.yml:
  #     > Dromelib::Config.yaml # => the full .dromelib.yml
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
      yaml.each do |key, value|
        instance_eval {
          instance_variable_set("@#{key}", OpenStruct.new(value))
          define_method key do
            instance_variable_get("@#{key}")
          end
        }
      end
    end

    def yaml
      @@yaml ||= YAML.load_file('.dromelib.yml')
    rescue Errno::ENOENT
      {}
    end
  end
end
