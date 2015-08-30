# Copyright 2015 The Cocktail Experience, S.L.
require 'neography'
require_relative '../dromelib'

module Dromelib
  # Class to send the dromes' activity to our Neo4j server throught Neography.
  class Neo4j
    class UnconfiguredError < StandardError; end

    attr_reader :klass

    def initialize(klass = nil)
      @klass = klass || Neography::Rest
    end

    def neo
      fail UnconfiguredError unless Neo4j.configured?
      @neo ||= @klass.new(Neo4j.rest_url)
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

      def host
        _init_required!
        Dromelib::Env.value_for(:neo4j_host) || Dromelib::Config.neo4j.host
      end

      def port
        _init_required!
        Dromelib::Env.value_for(:neo4j_port) || Dromelib::Config.neo4j.port
      end

      def configured?
        _init_required!
        (host && !host.empty? &&
         port && !port.empty?) || false
      end

      def credentials?
        (username && !username.empty? &&
         password && !password.empty?) || false
      end

      def rest_url
        if credentials?
          "http://#{username}:#{password}@#{host}:#{port}"
        else
          "http://#{host}:#{port}"
        end
      end

      private

      def _init_required!
        fail Dromelib::UninitializedError unless Dromelib.initialized?
      end
    end
  end
end
