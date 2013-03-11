vector = require '../core/math/vector'
Vec2 = vector.Vec2
Vec3 = vector.Vec3

physics = require './physics'
Behaviour = physics.Behaviour

###
  A constant force along a vector e.g. Gravity
###
class Force extends Behaviour
  constructor: (@force) ->
  apply: (particle) -> particle.position.add @force


module.exports =
  Force: Force