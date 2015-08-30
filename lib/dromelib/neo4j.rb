# Copyright 2015 The Cocktail Experience, S.L.
require 'neography'
require_relative '../dromelib'

module Dromelib
  # Class to send the dromes' activity to our Neo4j server throught Neography.
  class Neo4j
    attr_reader :klass

    def initialize(klass = nil)
      @klass = klass || Neography::Rest
    end

    class << self
      def username
        _init_required!
        Dromelib::Env.value_for(:neo4j_username) || Dromelib::Config.neo4j.username
      end

      def password
        _init_required!
        Dromelib::Env.value_for(:neo4j_password) || Dromelib::Config.neo4j.password
      end

      def server
        _init_required!
        Dromelib::Env.value_for(:neo4j_server) || Dromelib::Config.neo4j.server
      end

      def configured?
        _init_required!
        (server && !server.empty?) || false
      end

      private

      def _init_required!
        fail Dromelib::UninitializedError unless Dromelib.initialized?
      end
    end
  end
end
