# mocha unit test
should = require 'should'

fk = require '../lib/fieldkit'

describe 'Time', ->
  describe '#eval()', ->
    it 'should be able to parse a string as argument', ->
      t = new fk.Time("1s + 1s")
      t.value.should.equal 2000

    it 'should evaluate 1s + 1s = 2000', ->
      fk.Time.str("1s + 1s").value.should.equal 2000


describe 'Timespan', ->
  describe '#overlaps()', ->
    it 'should detect overlaps', ->
      t1 = new fk.Timespan(0, 100)

      t1.overlaps(new fk.Timespan(-50, 50)).should.be.true
      t1.overlaps(new fk.Timespan(50, 150)).should.be.true
      t1.overlaps(new fk.Timespan(-50, 150)).should.be.true

      t1.overlaps(new fk.Timespan(-50, -1)).should.be.false
      t1.overlaps(new fk.Timespan(120, 150)).should.be.false

