# mocha unit test
should = require 'should'

fk = require '../lib/fieldkit'

describe 'Math', ->
  describe '#fit()', ->
    it 'should be able to remap things', ->
      value = 0.5
      result = fk.math.fit value, 0, 0.5, 0, 1
      result.should.equal 1

      value = 0.25
      result = fk.math.fit value, 0, 0.5, 0, 1
      result.should.equal 0.5


    it 'should work with input values outside of its range', ->
      value = -0.5
      result = fk.math.fit value, 0, 0.5, 0, 1
      result.should.equal 0

      value = 33
      result = fk.math.fit value, 0, 0.25, 0, 1
      result.should.equal 1
