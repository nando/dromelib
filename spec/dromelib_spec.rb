# Copyright 2015 The Cocktail Experience, S.L.
require_relative 'spec_helper'

describe Dromelib do
  describe 'initialization' do
    after do
      Dromelib.end! if Dromelib.initialized?
    end

    it 'should be uninitialized after being just loaded' do
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
