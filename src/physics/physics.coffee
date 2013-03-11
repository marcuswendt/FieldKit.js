util = require '../core/util'
particleModule = require './particle'
Particle = particleModule.Particle


###

  A Particle Physics Simulation

###
class Physics
  # List of all particles in the simulation
  particles: []

  # List of all behaviours
  behaviours: []
  constraints: []

  # The particle emitter
  emitter: null

  constructor: ->
    @clear()

  clear: ->
    @particles = []
    @behaviours = []
    @constraints = []
    @emitter = new Emitter(this)

  addParticle: (particle) -> @particles.push particle

  # Add a behaviour or constraint to the simulation
  add: (effector, state=particleModule.State.Alive) ->
    list = if effector instanceof Constraint then @constraints else @behaviours

    list[state] = []  unless list[state]
    list[state].push effector


  update: ->
    @emitter.update()

    particles = @particles

    # apply behaviours
    @applyEffectors @behaviours, particles

    # apply constraints
    @applyEffectors @constraints, particles

    # update all particles
    dead = []
    stateDead = particleModule.State.Dead

    i = particles.length
    while i--
      p = particles[i]
      p.update()
      dead.push p if p.state is stateDead

    # remove dead particles
    i = dead.length
    while i--
      p = dead[i]
      util.removeElement p, particles


  # --- utilities ---

  # applies all effectors to the given particle list when their states match
  applyEffectors: (effectors, particles) ->
    state = effectors.length
    while state--
      stateEffectors = effectors[state]

      # apply all behaviours for this state if particle is in this state
      j = stateEffectors.length
      while j--
        e = stateEffectors[j]
        e.prepare this

        i = particles.length
        while i--
          particle = particles[i]
          e.apply particle if particle.state is state


  # returns the number of particles
  size: -> @particles.length


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


class Constraint
  prepare: ->
  apply: (particle) ->


module.exports =
  Physics: Physics
  Emitter: Emitter
  Behaviour: Behaviour
  Constraint: Constraint

