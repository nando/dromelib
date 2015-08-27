# Copyright 2015 The Cocktail Experience, S.L.
require 'neography'
require_relative '../dromelib'

module Dromelib
  # Module to send the dromes' activity to our favourite Neo4j server.
  module Neo4j
    extend self

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
