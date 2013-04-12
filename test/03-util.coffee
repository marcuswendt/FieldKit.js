# mocha unit test
should = require 'should'

fk = require '../lib/fieldkit'

describe 'Util', ->
  describe '#clone()', ->
    it 'should work with simple objects & properties', ->
      class Person
        constructor: (@name, @age) ->

      peter = new Person("Peter", 37)
      duplicate = fk.util.clone peter

      duplicate.name.should.equal peter.name
      duplicate.age.should.equal peter.age


    it 'should work with object hierarchies', ->
      class Person
        constructor: (@name, @age) ->

      peter = new Person("Peter", 37)
      peter.friend = new Person("Mike", 27)

      duplicate = fk.util.clone peter
      duplicate.friend.name.should.equal "Mike"
      duplicate.friend.age.should.equal 27


    it 'should return true object copies', ->
      class Person
        constructor: (@name, @age) ->

      peter = new Person("Peter", 37)
      peter.friend = new Person("Mike", 27)

      duplicate = fk.util.clone peter

      duplicate.friend.name = "Zorro"

      peter.friend.name.should.equal "Mike"
      duplicate.friend.name.should.equal "Zorro"
