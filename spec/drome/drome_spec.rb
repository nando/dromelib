# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../spec_helper'

describe Dromelib::Drome do
  let(:drome) { Dromelib::Drome.new }

  it 'should have :docudrome as default name' do
    drome.name.must_equal :docudrome
  end

  describe '#new_entry' do
    it 'should return an Entry instance' do
      drome.new_entry('SemVer').must_be_kind_of Dromelib::Entry
    end
  end
end
