###

  Force Directed Graph

###
class GNode
  children: []
  particle: null

  constructor: (@name) ->
    @children = []

  addNode: (name) ->
    node = new GNode @name + "/" + name
    @children.push node
    node

  getWeight: ->
    weight = @children.length
    for child in @children
      weight += child.getWeight()
    weight

  init: (graph, center, radius, parentSize = 0) ->
    physics = graph.physics
    weight = @getWeight()

    @particle = physics.emitter.create()

    @particle.size = Math.min weight / 2 + 3, 30

    @particle.position.set(center)

    alpha = Math.random() * Math.PI * 2
    jitter = (parentSize + @particle.size) * 2 + Math.random() * 10
    @particle.position.x += Math.sin(alpha) * jitter
    @particle.position.y += Math.cos(alpha) * jitter
    @particle.clearVelocity()

    @particle.color = new fk.Color(1, 1, 0)
    @particle.color.randomize()

    for child in @children
      radius = weight * 0.5 + @particle.size * 4
      child.init graph, @particle.position, radius, @particle.size
      graph.addLink @particle, child.particle


class Graph
  root: null

  constructor: (springIterations) ->
    @physics = new fk.physics.Physics()

    # use 2D particles
    @physics.emitter.type = fk.physics.Particle2
    @physics.emitter.rate = 0

    @physics.springIterations = springIterations

    # Behaviours
#    @physics.add new fk.physics.Force new fk.math.Vec2(0, 1), 0.01

    # Constraints
    collision = new fk.physics.Collision(@physics)
    @physics.add collision

    @root = new GNode this, "root"

  addLink: (parent, child) ->
    spring = new fk.physics.Spring parent, child
    @physics.addSpring spring
    spring

  # call this after all nodes are created
  init: (center) ->
    @root.init this, center, 0
    @root.particle.isLocked = true

  update: -> @physics.update()

  getBounds: ->
    rect = new fk.math.Rect(Number.MAX_VALUE, Number.MAX_VALUE, Number.MIN_VALUE, Number.MIN_VALUE)

    for particle in @physics.particles
      p = particle.position

      rect.x1 = p.x if p.x < rect.x1
      rect.y1 = p.y if p.y < rect.y1

      rect.x2 = p.x if p.x > rect.x2
      rect.y2 = p.y if p.y > rect.y2

    rect

  centerGraph: (screenCenter) ->
    bounds = @getBounds()
    offset = bounds.center().sub(screenCenter).scale(1)
#    offset = screenCenter.sub().div(2)

    console.log "screenCenter: #{screenCenter} bounds: #{bounds.center()} offset: #{offset}"

    for particle in @physics.particles
      particle.position.sub offset
      particle.clearVelocity()


class Example extends fk.client.Sketch
  State = fk.physics.State
  rng = new fk.math.Random()

  # Settings
  maxDepth = 3
  springIterations = 32
  warmupIterations = 16

  setup: ->
    # create graph structure
    @graph = new Graph(springIterations)

    createNodes = (parent, depth=0) ->
      numChildren = rng.int 0, (depth * 5)

      for i in [0..numChildren]
        child = parent.addNode "c#{i}"
        if depth < maxDepth
          createNodes child, depth + 1

    createNodes @graph.root

    # create drawing structure
    center = new fk.math.Vec2(@width / 2, @height / 2)
    @graph.init center

    # run simulation
    for i in [0..warmupIterations]
      @graph.update()

    # find min / max
    @graph.centerGraph center

  mouseDown: ->
#    @attractor.isEnabled = true

  mouseUp: ->
#    @attractor.isEnabled = false

  draw: ->
#    @attractor.target.set2 @mouseX, @mouseY

    # update
    @graph.update()

    # draw
    physics = @graph.physics
    @background(0)


    # draw springs
    @noFill()
    @stroke 128
    @lineWidth 1
    for spring in physics.springs
      @line spring.a.position, spring.b.position

    # draw particles
    @noStroke()
    @lineWidth 2
    for particle in physics.particles
      if particle.state == State.ALIVE
        if particle == @graph.root.particle
          @stroke 255
          @fill 255,0,0
        else
          @noStroke()
          @fill 255

        @circle particle.position.x, particle.position.y, particle.size


    # draw bounds
#    r = @graph.getBounds()
#    @noFill()
#    @stroke(255)
#    @rect r.x1, r.y1, r.width(), r.height()
#
#    @fill(255)
#    @rect r.center().x, r.center().y, 6, 6