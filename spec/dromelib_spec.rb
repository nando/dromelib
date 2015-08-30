# Copyright 2015 The Cocktail Experience, S.L.
require_relative 'spec_helper'

describe Dromelib do
  after do
    Dromelib.end!
  end

  describe 'initialization' do
    it 'should not be initialized until ::init! is called' do
      _(Dromelib).wont_be :initialized?
    end

    it 'should be initialized/un-initialized after calling ::init!/::end!' do
      Dromelib.init!
      _(Dromelib).must_be :initialized?
      Dromelib.end!
      _(Dromelib).wont_be :initialized?
    end
  end

  describe '::drome (default Drome instance)' do
    it 'should raise UninitializedError unless Dromelib.init! has been called first' do
      proc do
        Dromelib.drome
      end.must_raise Dromelib::UninitializedError
    end

    it 'should return the Docudrome instance if Dromelib.init! has been called' do
      Dromelib.init!
      _(Dromelib.drome.name).must_equal :docudrome
    end
  end

  describe '::load_drome method' do
    before do
      Dromelib.init!
    end

    it 'should return the default drome if called without params' do
      _(Dromelib.load_drome).must_equal Dromelib.drome
    end

    # TODO: I think next specs should be in the Drome's specs an here just the
    #   expectation about the Drome class method being called.
    it 'should return the right drome if called with its symbol' do
      _(Dromelib.load_drome(:lovedrome).name).must_equal :lovedrome
    end

    it 'should return the right drome if called with its string representation' do
      _(Dromelib.load_drome('lovedrome').name).must_equal :lovedrome
    end

    it 'should be case unsensitive' do
      _(Dromelib.load_drome('LovedRome').name).must_equal :lovedrome
    end
  end

  describe '::neo4j' do
    let(:my_klass) { :AwesomeKlass }

    it 'should raise UninitializedError unless Dromelib.init! has been called first' do
      proc do
        Dromelib.neo4j
      end.must_raise Dromelib::UninitializedError
    end

    it 'should return a Neo4j object' do
      Dromelib.init!
      _(Dromelib.neo4j).must_be_kind_of Dromelib::Neo4j
    end

    it 'should let the ::init! specify the klass used by the Neo4j instance' do
      Dromelib.init! neo4j: my_klass
      _(Dromelib.neo4j.klass).must_equal my_klass
    end
  end
end
