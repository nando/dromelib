# Copyright 2015 The Cocktail Experience, S.L.
module Dromelib
  # Anything having a name (a.k.a. "auido") that lives in the context of a Drome
  # instance.
  class Entry
    attr_reader :drome, :auido

    def initialize(*args)
      first_param = args[0]
      if args.size == 1
        fail ArgumentError unless first_param.is_a?(Hash)
        _initialize first_param[:drome], first_param[:auido]
      elsif args.size == 2
        _initialize first_param, args[1]
      end
    end

    def save!
      puts "Saving #{@drome.name}'s '#{@auido}'..."
    end

    private

    def _initialize(drome, auido)
      fail ArgumentError unless drome.is_a?(Dromelib::Drome) && auido.is_a?(String)
      @drome = drome
      @auido = auido
    end
  end
end