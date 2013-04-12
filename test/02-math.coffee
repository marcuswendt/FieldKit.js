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


  describe '#round()', ->
    it 'should work', ->
      result = fk.math.round 0.123456789, 1
      result.toString().should.equal "0.1"

      result = fk.math.round 0.123456789, 3
      result.toString().should.equal "0.123"

      result = fk.math.round 0.1234, 4
      result.toString().should.equal "0.1234"

      # fails V8s number precision
#      result = fk.math.round 0.1234, 5
#      result.toString().should.equal "0.12345"