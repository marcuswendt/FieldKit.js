vector = require '../math/vector'
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

  toString: -> "Box(#{@min}, #{@max})"


###
  2D version of Box.
###
class Area extends Constraint
  constructor: (@min = new Vec2(), @max = new Vec2(100, 100)) ->

  apply: (particle) ->
    pos = particle.position

    pos.x = @min.x if pos.x < @min.x
    pos.y = @min.y if pos.y < @min.y

    pos.x = @max.x if pos.x > @max.x
    pos.y = @max.y if pos.y > @max.y

  toString: -> "Area(#{@min}, #{@max})"


###
  Keeps a particle within a certain 2D region by wrapping it around a given area.
###
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

  toString: -> "Wrap2(#{@min}, #{@max})"


###
  Keeps a particle within a certain 2D region by wrapping it around a given area.
###
class Wrap3 extends Constraint
  delta = new Vec3()

  constructor: (@min = new Vec3(), @max = new Vec3(100, 100, 100)) ->

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

    if pos.z < @min.z
      pos.z += delta.z
      prev.z += delta.z

    if pos.x > @max.x
      pos.x -= delta.x
      prev.x -= delta.x

    if pos.y > @max.y
      pos.y -= delta.y
      prev.y -= delta.y

    if pos.z > @max.z
      pos.z -= delta.z
      prev.z -= delta.z

  toString: -> "Wrap3(#{@min}, #{@max})"


###
  Stops particles from colliding with each other.
###
class Collision extends Constraint
  physics: null
  searchRadius: 100
#  bouncyness: 1

  constructor: (@physics) ->

  apply: (particle) ->
    position = particle.position
    delta = position.clone()

    neighbours = @physics.space.search position, @searchRadius

#    if particle.id == 0
#      console.log "found #{neighbours.length} particles"

    for neighbour in neighbours
      continue if neighbour == particle

      # vector from particle to neighbour
      delta.set(position).sub neighbour.position

      distSq = delta.lengthSquared()

      radius = particle.size + neighbour.size
      radiusSq = radius * radius

      if distSq < radiusSq
        dist = Math.sqrt distSq
        delta.scale (dist - radius)/ radius * 0.5

        # slightly faster method
        # delta.scale (distSq - radiusSq)/ radiusSq * 0.25

        particle.position.sub delta
        neighbour.position.add delta
      undefined
    undefined



module.exports =
  Box: Box
  Area: Area
  Wrap2: Wrap2
  Wrap3: Wrap3
  Collision: Collision

