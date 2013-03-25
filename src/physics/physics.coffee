util = require '../util'
particleModule = require './particle'
Particle = particleModule.Particle


###

  A Particle Physics Simulation

###
class Physics
  # List of all particles in the simulation
  particles: []

  # List of all spring constraints in the simulation
  springs: []

  # List of all behaviours
  behaviours: []
  constraints: []

  # The particle emitter
  emitter: null

  # The spatial optimisation manager to use
  space: null

  # Settings
  constraintIterations: 1
  springIterations: 1

  constructor: ->
    @space = new Space()
    @emitter = new Emitter(this)
    @clear()

  clear: ->
    @particles = []
    @behaviours = []
    @constraints = []

  # polymorphic add
  add: ->
    return if arguments.length == 0
    arg = arguments[0]

    if arg instanceof Particle
      @addParticle arg

    else if arg instanceof Behaviour
      console.log "adding behaviour #{arg}"
      state = arguments[1] if arguments.length > 1
      @addBehaviour arg, state

    else if arg instanceof Spring
      console.log "adding spring #{arg}"
      @addSpring arg

    else
      "Cannot add #{arg}"

    arg

  addParticle: (particle) ->
    @particles.push particle
    particle

  addSpring: (spring) ->
    @springs.push spring
    spring

  # Add a behaviour or constraint to the simulation
  addBehaviour: (effector, state=particleModule.State.ALIVE) ->
    list = if effector instanceof Constraint then @constraints else @behaviours

    list[state] = []  unless list[state]
    list[state].push effector


  update: ->
    @emitter.update()

    @space.update(this)

    particles = @particles

    # apply behaviours
    @applyEffectors @behaviours, particles

    # apply constraints
    for j in [0..@constraintIterations]
      @applyEffectors @constraints, particles

      for i in [0..@springIterations]
        # update springs
        for spring in @springs
          spring.update()

    # update all particles
    dead = []
    stateDead = particleModule.State.DEAD

    for particle in particles
      particle.update()
      dead.push particle if particle.state is stateDead
      undefined

    # remove dead particles
    i = dead.length
    while i--
      particle = dead[i]
      util.removeElement particle, particles
      undefined
    undefined


  # --- utilities ---

  # applies all effectors to the given particle list when their states match
  applyEffectors: (effectors, particles) ->
    # go through all states in effectors list
    state = effectors.length
    while state--
      stateEffectors = effectors[state]

      # apply all behaviours for this state if particle is in this state
      for effector in stateEffectors
        effector.prepare this

        for particle in particles
          if particle.state is state and not particle.isLocked
            effector.apply particle
          undefined

        undefined
      undefined
    undefined

  # returns the number of particles
  size: -> @particles.length


###
  Spatial Search

  Simple brute force spatial searches.
  Subclasses may override this to organise particles so they can be found quicker later
###
class Space
  physics = null

  constructor: ->

  update: (physics_) -> physics = physics_

  search: (center, radius) ->
    result = []
    radiusSq = radius * radius

    for particle in physics.particles
      if center.distanceSquared(particle.position) < radiusSq
        result.push particle

    result


###
  Particle Emitter
###
class Emitter
  rate: 1
  interval: 1
  max: 100

  # @override to create your own particle type
  type: particleModule.Particle3

  # local vars
  timer = -1
  id = 0

  # created with a reference to the original physics particle array
  constructor: (@physics) ->

  update: ->
    if timer is -1 or timer >= @interval
      timer = 0
      i = 0

      while i < @rate and @physics.size() < @max
        p = @create()
        @init p
        i++

    timer++

  create: ->
    p = new @type(id++)
    @physics.addParticle p
    p

  # @overridable initialiser function run on all newly created particles
  init: (particle) ->



###
  Base class for all physical forces, behaviours & constraints
###
class Behaviour
  prepare: ->
  apply: (particle) ->


class Constraint extends Behaviour
  prepare: ->
  apply: (particle) ->



###
  Verlet Spring
###
class Spring
  a: null # first particle
  b: null # second particle
  restLength: 0
  strength: 0.5

  constructor: (@a, @b, @strength = 0.5) ->
    @restLength = @a.position.distance @b.position

  update: ->
    delta = @b.position.sub_ @a.position
    dist = delta.length() + Number.MIN_VALUE

    normDistStrength = (dist - @restLength) / dist * @strength

    return if normDistStrength == 0

    delta.scale normDistStrength

    if not @a.isLocked
#      @a.position.add delta.scale_ normDistStrength
      @a.position.add delta

    if not @b.isLocked
      @b.position.sub delta

  toString: -> "Spring(#{a}, #{b})"


module.exports =
  Physics: Physics
  Emitter: Emitter
  Space: Space
  Behaviour: Behaviour
  Constraint: Constraint
  Spring: Spring

