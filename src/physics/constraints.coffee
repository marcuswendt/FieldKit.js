vector = require '../core/math/vector'
Vec2 = vector.Vec2
Vec3 = vector.Vec3

physics = require './physics'
Constraint = physics.Constraint


###
  Keeps the particle inside the given 3D box
###
class Box extends Constraint
  constructor: (@min = new Vec3(), @max = new Vec3(100, 100, 100)) ->

  apply: (particle) ->
    pos = particle.position

    pos.x = @min.x if pos.x < @min.x
    pos.y = @min.y if pos.y < @min.y
    pos.z = @min.z if pos.z < @min.z

    pos.x = @max.x if pos.x > @max.x
    pos.y = @max.y if pos.y > @max.y
    pos.z = @max.z if pos.z > @max.z


###
  2D version of Box
###
class Area extends Constraint
  constructor: (@min = new Vec2(), @max = new Vec2(100, 100)) ->

  apply: (particle) ->
    pos = particle.position

    pos.x = @min.x if pos.x < @min.x
    pos.y = @min.y if pos.y < @min.y

    pos.x = @max.x if pos.x > @max.x
    pos.y = @max.y if pos.y > @max.y


class Wrap2 extends Constraint
  delta = new Vec2()

  constructor: (@min = new Vec2(), @max = new Vec2(100, 100)) ->

  prepare: -> delta.set(@max).sub(@min)

  apply: (particle) ->
    pos = particle.position
    prev = particle.prev

    if pos.x < @min.x
      pos.x += delta.x
      prev.x += delta.x

    if pos.y < @min.y
      pos.y += delta.y
      prev.y += delta.y

    if pos.x > @max.x
      pos.x -= delta.x
      prev.x -= delta.x

    if pos.y > @max.y
      pos.y -= delta.y
      prev.y -= delta.y


module.exports =
  Box: Box
  Area: Area
  Wrap2: Wrap2
