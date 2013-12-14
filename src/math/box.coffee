Vec3 = require("./vector").Vec3

class Box
  x1: 0
  y1: 0
  z1: 0

  x2: 0
  y2: 0
  z2: 0

  constructor: (@x1=0, @y1=0, @z1=0, @x2=0, @y2=0, @z2=0) ->

  center: ->
    x = Math.min(@x1, @x2) + @width() * 0.5
    y = Math.min(@y1, @y2) + @height() * 0.5
    z = Math.min(@z1, @z2) + @depth() * 0.5
    new Vec3(x, y, z)

  width: -> Math.abs(@x1 - @x2)

  height: -> Math.abs(@y1 - @y2)

  depth: -> Math.abs(@z1 - @z2)

module.exports.Box = Box