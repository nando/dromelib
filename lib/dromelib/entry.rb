# Copyright 2015 The Cocktail Experience, S.L.
module Dromelib
  # Anything having a name (a.k.a. "auido") that lives in the context of a Drome
  # instance.
  class Entry
    attr_reader :drome, :auido, :created_at

    def initialize(*args)
      first_param = args[0]
      if args.size == 1
        fail ArgumentError unless first_param.is_a?(Hash)
        _initialize first_param[:drome], first_param[:auido], first_param[:timestamp]
      else
        _initialize first_param, args[1], args[2]
      end
    end

    def save!
      puts "Saving #{@drome.name}'s '#{@auido}'..."
    end

    private

    def _initialize(drome, auido, created_at)
      fail(ArgumentError, drome) unless drome.is_a?(Dromelib::Drome)
      fail(ArgumentError, auido) unless auido.respond_to?(:to_sym)
      @drome = drome
      @auido = auido.to_sym
      @created_at = created_at || Time.now.utc
    end
  end
end
