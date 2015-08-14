# Copyright 2015 The Cocktail Experience, S.L.
module Dromelib
  # A place where any entry is welcome.
  class Drome
    attr_reader :name

    def initialize(name = :docudrome)
      @name = name
    end

    def new_entry(auido)
      Dromelib::Entry.new(drome: self, auido: auido)
    end
  end
end
