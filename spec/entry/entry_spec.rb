# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../spec_helper'

describe Dromelib::Entry do
  describe '.initialize' do
    it 'should require the entry name (i.e. "auido")' do
      proc do
        Dromelib::Entry.new
      end.must_raise ArgumentError
    end
  end
end
