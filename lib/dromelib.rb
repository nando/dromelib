# Copyright 2015 The Cocktail Experience, S.L.
require_relative 'dromelib/version'
require_relative 'dromelib/config'
require_relative 'dromelib/env'
require_relative 'dromelib/drome'
require_relative 'dromelib/entry'
require_relative 'dromelib/neo4j'
require_relative 'dromelib/gmail'

# Usage:
#   * 1st require the lib
#     > require './path/to/lib/dromelib'
#
#   * 2nd call its init! method
#     > Dromelib.init!
#
#   * 3rd do what ever you want in your "dromeland"
#     > # p.e. see the Neo4j password that the lib will use:
#     > Dromelib::Config.environment_vars.neo4j.password
#     > # or access the full raw yaml config loaded from .dromelib.yml files:
#     > Dromelib::Config.yaml # => the full .dromelib.yml
#     > Dromelib::GMail.import! # get possible new citizens from your email
#
#   * 4th [optional] close it (needed for testing)
#     > Dromelib.end!
module Dromelib
  class UninitializedError < StandardError; end

  module_function

  # rubocop:disable Style/ClassVars
  @@initialized = false
  @@dromes = {}
 
  def init!(klasses = {})
    Config.load_yaml!
    @@dromes[:docudrome] = Dromelib::Drome.new
    @@neo4j = Dromelib::Neo4j.new(klasses[:neo4j])

    @@initialized = true
  end

  def end!
    Config.remove_yaml!
    !(@@initialized = false)
  end

  def initialized?
    @@initialized
  end

  def drome
    fail UninitializedError unless initialized?
    @@dromes[:docudrome]
  end

  def neo4j
    fail UninitializedError unless initialized?
    @@neo4j
  end
  # rubocop:enable Style/ClassVars

  def load_drome(dromename = nil)
    dromename ||= :docudrome
    @@dromes[dromename] ||= Dromelib::Drome.open(dromename)
  end
end
