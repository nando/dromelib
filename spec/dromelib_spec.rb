# Copyright 2015 The Cocktail Experience, S.L.
require_relative 'spec_helper'

describe Dromelib do
  after do
    Dromelib.end!
  end

  describe 'initialization' do
    it 'should not be initialized until .init! is called' do
      refute Dromelib.initialized?
    end

    it 'should be initialized/un-initialized after calling .init!/.end!' do
      Dromelib.init!
      assert Dromelib.initialized?
      Dromelib.end!
      refute Dromelib.initialized?
    end
  end

  describe '.drome (default Drome instance)' do
    it 'should raise UninitializedError unless Dromelib.init! has been called first' do
      proc do
        Dromelib.drome
      end.must_raise Dromelib::UninitializedError
    end

    it 'should return a Drome instance if Dromelib.init! has been called' do
      Dromelib.init!
      Dromelib.drome.must_be_kind_of Dromelib::Drome
    end
  end
end
