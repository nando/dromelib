# Copyright 2015 The Cocktail Experience, S.L.
module Dromelib
  class Entry
    def initialize(auido)
      @auido = auido
    end

    def save!
      puts auido
    end
  end
end
