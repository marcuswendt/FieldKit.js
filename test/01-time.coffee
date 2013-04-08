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

    it 'should return its value in seconds', ->
      t = new fk.Time(10000)
      t.s.should.equal 10


describe 'Timespan', ->
  describe '#overlaps()', ->
    it 'should detect overlaps', ->
      ts = new fk.Timespan(0, 100)

      ts.overlaps(new fk.Timespan(-50, 50)).should.be.true
      ts.overlaps(new fk.Timespan(50, 150)).should.be.true
      ts.overlaps(new fk.Timespan(-50, 150)).should.be.true

      ts.overlaps(new fk.Timespan(-50, -1)).should.be.false
      ts.overlaps(new fk.Timespan(120, 150)).should.be.false

  describe '#str()', ->
    it 'should be able to parse simple timespan strings', ->
      ts = fk.Timespan.str("0..1000ms")
      ts.from.value.should.equal 0
      ts.to.value.should.equal 1000

    it 'should be able to parse complex timespan strings', ->
      ts = fk.Timespan.str("1s * 4 / 2 .. 1s * 10")
      ts.from.value.should.equal 2000
      ts.to.value.should.equal 10000

    it 'should resolve Time objects', ->
      duration = fk.Time.s 2
      ts = fk.Timespan.str "#{duration} - 1s .. #{duration}"
      ts.from.value.should.equal 1000
      ts.to.value.should.equal 2000

    it 'should resolve seconds and frames', ->
      fps = 30
      ts = new fk.Timespan.str "1f .. 1s", fps
      ts.from.value.should.equal 1000 / fps
      ts.to.value.should.equal 1000

    it 'should handle complex calculations of seconds and frames', ->
      fps = 30
      ts = new fk.Timespan.str "1s + 1f .. 1s * 2", fps
      ts.from.value.should.equal 1000 + 1000 / fps
      ts.to.value.should.equal 2000

  describe '#segmentByInterval()', ->
    it 'should work with an even interval', ->
      r = fk.Timespan.s(1).segmentByInterval fk.Time.ms(250)
      r.length.should.equal 4

    it 'should work with an uneven interval', ->
      r = fk.Timespan.s(1).segmentByInterval fk.Time.ms(255)
      r.length.should.equal 4

    it 'should work with an uneven interval and snapping', ->
      r = fk.Timespan.s(1).segmentByInterval fk.Time.ms(255), true
      r.length.should.equal 4
      r[3].to.value.should.equal 1000