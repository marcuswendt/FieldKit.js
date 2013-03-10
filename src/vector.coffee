#
# Vector 2D
#
class Vec2
  x: 0
  y: 0

  constructor: (@x, @y) ->

  set: (v) -> @x = v.x; @y = v.y; this
  set2: (x, y) -> @x = x; @y = y; this

  zero: -> @x = 0; @y = 0; this

  add: (v) -> @x += v.x; @y += v.y; this
  add_: (v) -> new Vec2(@x + v.x, @y + v.y)

  sub: (v) -> @x -= v.x; @y -= v.y; this
  sub_: (v) -> new Vec2(@x - v.x, @y - v.y)

  mul: (v) -> @x *= v.x; @y *= v.y; this
  mul_: (v) -> new Vec2(@x * v.x, @y * v.y)

  div: (v) -> @x /= v.x; @y /= v.y; this
  div_: (v) -> new Vec2(@x / v.x, @y / v.y)

  scale: (value) -> @x *= value; @y *= value; this
  scale_: (value) -> new Vec2(@x * value, @y * value)

  length: -> Math.sqrt @x * @x + @y * @y
  lengthSquared: -> @x * @x + @y * @y

  normalize: ->
    l = @length()
    unless l is 0
      @x /= l
      @y /= l
    this

  normalizeTo: (length) ->
    magnitude = Math.sqrt(@x * @x + @y * @y)
    if magnitude > 0
      magnitude = length / magnitude
      @x *= magnitude
      @y *= magnitude
    this

  distance: (v) -> Math.sqrt @distanceSquared2(v.x, v.y)
  distanceSquared: (v) -> @distanceSquared2 v.x, v.y

  distanceSquared2: (x, y) ->
    dx = @x - x
    dy = @y - y
    dx * dx + dy * dy

  dot: (v) -> @x * v.x + @y * v.y

  rotate: (angle) ->
    sina = Math.sin(angle)
    cosa = Math.cos(angle)
    rx = @x * cosa - @y * sina
    ry = @x * sina + @y * cosa
    @x = rx
    @y = ry

  jitter: (amount) ->
    @x += Random.float(-1, 1) * amount
    @y += Random.float(-1, 1) * amount
    this

  jitter_: (amount) -> (new Vec2(@x, @y)).jitter amount

  lerp: (target, delta) ->
    @x = @x * (1 - delta) + target.x * delta
    @y = @y * (1 - delta) + target.y * delta
    this

  lerp_: (target, delta) ->
    (new Vec2(@x, @y)).lerp target, delta

  equals: (v) -> @x is v.x and @y is v.y

  clone: -> new Vec2(@x, @y)

  toString: -> "Vec2[" + @x + "," + @y + "]"


module.exports =
  Vec2: Vec2