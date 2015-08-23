# Copyright 2015 The Cocktail Experience, S.L.
require_relative '../spec_helper'

describe Dromelib::Entry do
  describe '.new requires a Drome instance and an "auido" (i.e. name)' do
    let(:drome) { Dromelib::Drome.new }
    let(:auido) { :'Entry "auido"' }
    let(:timestamp) { Time.now.utc }

    describe 'successful instance creation' do
      after do
        _(@entry.drome).must_equal drome
        _(@entry.auido).must_equal auido
      end

      it 'works with two Drome+String consecutive instances' do
        @entry = Dromelib::Entry.new(drome, auido)
      end

      it 'works with them as values of :drome & :auido in a Hash' do
        @entry = Dromelib::Entry.new(drome: drome, auido: auido)
      end

      it 'should let us specify #created_at as third argument' do
        @entry = Dromelib::Entry.new(drome, auido, timestamp)
        _(@entry.created_at).must_equal timestamp
      end

      it 'should let us specify #created_at as the :at value of the Hash' do
        @entry = Dromelib::Entry.new(drome: drome, auido: auido, at: timestamp)
        _(@entry.created_at).must_equal timestamp
      end
    end

    it 'should raise ArgumentError if created with a non-hash param' do
      proc do
        Dromelib::Entry.new drome
      end.must_raise ArgumentError
    end

    it 'should require a Drome & String consecutive instances (if not a hash)' do
      proc do
        Dromelib::Entry.new auido, drome
      end.must_raise ArgumentError
    end
  end
end
