# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../spec_helper'

describe Dromelib::Drome do
  describe '#new_entry' do
    it 'should return an Entry instance' do
      Dromelib::Drome.new_entry('SemVer').must_be_kind_of Dromelib::Entry
    end
  end
end
