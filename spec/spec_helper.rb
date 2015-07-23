# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../lib/dromelib'

require 'minitest/spec'
require 'minitest/autorun'

require 'climate_control'

require 'minitest/unit'
require 'mocha/mini_test'

require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new]

module Dromelib
  module Minitest
    extend self
    # Just an empty hash with main sections of the .dromelib.yml (that way we
    # can forget about other classes sections in our class spec).
    def sections_hash
      Dromelib::Config.gem_yaml.keys.inject({}) do |hash, section|
        hash[section] = {}
        hash
      end
    end
  end
end
