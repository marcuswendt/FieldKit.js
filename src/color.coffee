###



###
class Color
  r: 1
  g: 1
  b: 1
  a: 1

  constructor: (@r=1, @g=1, @b=1, @a=1) ->

  set: (color) ->
    @r = color.r
    @g = color.g
    @b = color.b
    @a = color.a
    this

  set3: (r, g, b) ->
    @r = r
    @g = g
    @b = b
    this

  randomize: ->
    @r = Math.random()
    @g = Math.random()
    @b = Math.random()
    this

  clone: -> new Color(@r, @g, @b, @a)

  equals: (other) ->
    return false if not other?
    @r == other.r and @g == other.g and @b == other.b and @a == other.a

  toCSS: ->
    r = Math.floor 255 * @r
    g = Math.floor 255 * @g
    b = Math.floor 255 * @b
    "rgba(#{r},#{g},#{b},#{@a})"

  toString: ->
    "fk.Color(#{@r},#{@g},#{@b},#{@a})"

module.exports =
  Color: Color