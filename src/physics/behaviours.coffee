vector = require '../math/vector'
Vec2 = vector.Vec2
Vec3 = vector.Vec3

physics = require './physics'
Behaviour = physics.Behaviour


###

  A constant force along a vector e.g. Gravity.
  Works in 2D + 3D.

###
class Force extends Behaviour
  force = null

  constructor: (@direction, @weight=1) ->

  prepare: -> force = @direction.normalizeTo(@weight)

  apply: (particle) -> particle.position.add force

  toString: -> "Force(#{force})"


###

  Attracts each particle within range to a target point.
  Works in 2D + 3D.

###
class Attractor
  tmp = null
  rangeSq = 0

  constructor: (@target, @range, @weight=1) ->
    tmp = @target.clone()

  prepare: -> rangeSq = @range * @range

  apply: (particle) ->
    tmp.set(@target).sub particle.position
    distSq = tmp.lengthSquared()
    if distSq > 0 and distSq < rangeSq

      # normalize and inverse proportional weight
      dist = Math.sqrt(distSq)
      tmp.scale (1 / dist) * (1 - dist / @range) * @weight
      particle.force.add tmp

  toString: -> "Attractor(#{@target}, #{@range}, #{@weight})"

module.exports =
  Force: Force
  Attractor: Attractor