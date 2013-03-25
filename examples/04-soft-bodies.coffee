###

  Soft Body Dynamics

###
class Example extends fk.client.Sketch
  Vec2 = fk.math.Vec2
  State = fk.physics.State

  rng = new fk.math.Random()
  cMouse = new fk.Color(1,1,0)

  setup: ->
    @physics = new fk.physics.Physics()
    @physics.constraintIterations = 1
    @physics.springIterations = 16 # should be equals the maximum number of springs connected to a single object

    # use 2D particles
    @physics.emitter.type = fk.physics.Particle2
    @physics.emitter.rate = 0

    # Gravity
    @physics.add new fk.physics.Force new Vec2(0, 1), 0.65

    # makes sure our particles never leave the canvas
    @physics.add new fk.physics.Area new Vec2(), new Vec2(@width, @height-100)

#    @physics.add new fk.physics.Collision(@physics)

#    a = @a
#    class CustomAttractor extends fk.physics.Attractor
#      tmp = a.position.clone()
#      rangeSq = 0
#
#      isEnabled: false
#
#      prepare: -> rangeSq = @range * @range
#
#      apply: (particle) ->
#        if @isEnabled and particle == a
#          tmp.set(@target).sub particle.position
#          distSq = tmp.lengthSquared()
#          if distSq > 0 and distSq < rangeSq
#
#            # normalize and inverse proportional weight
#            dist = Math.sqrt(distSq)
##            tmp.scale (1 / dist) * (1 - dist / @range) * @weight
#            tmp.normalize().scale @weight
#            particle.force.add tmp
#
#    @attractor = new CustomAttractor new Vec2(), 150, 1.0
#    @physics.addBehaviour @attractor

    @makeCreature @width / 2, @height / 2

  makeCreature: (x, y) ->

    sizeMin = 100
    sizeMax = 150

    center = particle = @physics.emitter.create()
    particle.setPosition2 x, y

    nPoints = fk.math.randI 8, 64
    hull = []
    alpha = 0
    for i in [0..nPoints]
        alpha += Math.PI * 2 / nPoints

        jitter = sizeMin + Math.random() * (sizeMax - sizeMin)

        particle = @physics.emitter.create()

        particle.position.set center.position
        particle.position.x += Math.sin(alpha) * jitter
        particle.position.y += Math.cos(alpha) * jitter
        particle.clearVelocity()

        particle.size = 3

        hull.push particle

    createLink = (a, b, strength) =>
      spring = @physics.addSpring new fk.physics.Spring a, b, strength
      spring

    # create exterior springs
    for particle, i in hull
      prev = if i == 0 then hull[ hull.length - 1] else hull[ i-1 ]
      spring = createLink particle, prev, 0.3
      spring.color = new fk.Color(1,1,0)

    # create interior support springs
    for particle, i in hull
      if fk.math.randF(0,1) > 0.25
        spring = createLink particle, center, 0.5
        spring.color = new fk.Color(0,1,1)


  mouseDown: ->
    @makeCreature @mouseX, @mouseY
#    @attractor.isEnabled = true

  mouseUp: ->
#    @attractor.isEnabled = false

  draw: ->
#
#    @attractor.target.set2 @mouseX, @mouseY

    # update physics
    @physics.update()

    # -- Draw --
    @background(0)

    # draw springs
    @noFill()
    @lineWidth 2
    @stroke 255
    for spring in @physics.springs
      @stroke spring.color
      @line spring.a.position, spring.b.position

    # draw particles
    @noStroke()
    for particle in @physics.particles
      @fill 255
      @circle particle.position.x, particle.position.y, particle.size

    # draw mouse
#    if @attractor.isEnabled
#      @fill 0, 255, 0
#      @circle this.mouseX, this.mouseY, 7
