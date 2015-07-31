# Copyright 2015 The Cocktail Experience, S.L.
require_relative 'spec_helper'

describe Dromelib do
  describe 'initialization' do
    after do
      Dromelib.end!
    end

    it 'should not be initialized just requiring the library' do
      refute Dromelib.initialized?
    end

    it 'should be initialized/un-initialized after calling .init!/.end!' do
      Dromelib.init!
      assert Dromelib.initialized?
      Dromelib.end!
      refute Dromelib.initialized?
    end
  end
end
