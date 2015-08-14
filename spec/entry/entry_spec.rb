# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../spec_helper'

describe Dromelib::Entry do
  describe '.new requires a Drome instance and an "auido" (i.e. name)' do
    let(:drome) { Dromelib::Drome.new }
    let(:string) { 'Entry "auido"' }

    describe 'successful instance creation' do
      after do
        @entry.drome.must_equal drome
        @entry.auido.must_equal string
      end

      it 'should do it with two Drome+String consecutive instances' do
        @entry = Dromelib::Entry.new(drome, string)
      end

      it 'should do it with them as values of :drome & :auido in a Hash' do
        @entry = Dromelib::Entry.new(drome: drome, auido: string)
      end
    end

    it 'should raise ArgumentError if created with a non-hash param' do
      proc do
        Dromelib::Entry.new drome
      end.must_raise ArgumentError
    end

    it 'should require a Drome & String consecutive instances (if not a hash)' do
      proc do
        Dromelib::Entry.new string, drome
      end.must_raise ArgumentError
    end
  end
end
