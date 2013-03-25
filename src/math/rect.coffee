Vec2 = require("./vector").Vec2

class Rect
  x1: 0
  y1: 0
  x2: 0
  y2: 0

  constructor: (@x1=0, @y1=0, @x2=0, @y2=0) ->

  center: ->
    x = Math.min(@x1, @x2) + @width() * 0.5
    y = Math.min(@y1, @y2) + @height() * 0.5
    new Vec2(x, y)

  width: -> Math.abs(@x1 - @x2)

  height: -> Math.abs(@y1 - @y2)

module.exports.Rect = Rect