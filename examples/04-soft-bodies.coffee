###

  Soft Body Dynamics

###
class Example extends fk.client.Sketch
  Vec2 = fk.math.Vec2
  State = fk.physics.State

  rng = new fk.math.Random()

  cMouse = new fk.Color(1,1,0)

  setup: ->
#    console.log "w #{@width} h #{@height}"

    @timer = new fk.Timer()
    @tempo = new fk.Tempo()

    # -- Physics --
    @physics = new fk.physics.Physics()

    # use 2D particles
    @physics.emitter.type = fk.physics.Particle2

    @physics.emitter.rate = 0
    @physics.emitter.max = 1000


    @a = @physics.emitter.create()
    @a.color = new fk.Color 1,0,0
    @a.size = 5
    @a.setPosition2 @width/2, @height * 1 / 4

    for i in [0..5]
      b = @physics.emitter.create()
      b.color = new fk.Color 1,1,0
      b.size = 10

      pos = @a.position.jitter_ @width * 0.25
      b.setPosition pos

      @physics.addSpring new fk.physics.Spring @a, b

    # randomize birth position
#    @physics.emitter.init = (particle) =>
#      particle.setPosition2 @width / 2, ((Math.random() * 2 - 1) * 0.25 + 0.5) * @height
#      particle.force.set2 (Math.random() * 2 - 1) * 10.1, 0
#
#      particle.lifetime = rng.int 60, 120
#      particle.size = 5

    #      particle.setPosition2 Math.random() * @width, Math.random() * @height

    # Gravity
#    @physics.addBehaviour new fk.physics.Force new Vec2(0, 1), 0.01

    # makes sure our particles never leave the canvas
#    @physics.addBehaviour new fk.physics.Wrap2 new Vec2(), new Vec2(@width, @height)

    a = @a
    class CustomAttractor extends fk.physics.Attractor
      tmp = a.position.clone()
      rangeSq = 0

      isEnabled: false

      prepare: -> rangeSq = @range * @range

      apply: (particle) ->
        if @isEnabled and particle == a
          tmp.set(@target).sub particle.position
          distSq = tmp.lengthSquared()
          if distSq > 0 and distSq < rangeSq

            # normalize and inverse proportional weight
            dist = Math.sqrt(distSq)
#            tmp.scale (1 / dist) * (1 - dist / @range) * @weight
            tmp.normalize().scale @weight
            particle.force.add tmp

    @attractor = new CustomAttractor new Vec2(), 150, 1.0
    @physics.addBehaviour @attractor

  mouseDown: ->
    @attractor.isEnabled = true

  mouseUp: ->
    @attractor.isEnabled = false

  draw: ->
    dt = @timer.update()
#    beat = @tempo.update dt
#
#    #    console.log "bar: #{@tempo.bars} beat: #{@tempo.beats}"
#
#    if @tempo.onBar and @tempo.bars % 5 == 0
#      console.log "beep"
#      @physics.emitter.rate = 250
#    else
#      @physics.emitter.rate = 0
#
    @attractor.target.set2 @mouseX, @mouseY

    # update physics
    @physics.update()

    # -- Draw --
    @background(0)

    # draw springs
    @noFill()
    @stroke 255
    @lineWidth 2
    for spring in @physics.springs
      @line spring.a.position, spring.b.position

    # draw particles
    @noStroke()
    for particle in @physics.particles
      if particle.state == State.ALIVE
#        life = 1 - (particle.age / particle.lifetime)
#        @fill 255, life
        @fill particle.color
        @circle particle.position.x, particle.position.y, particle.size

    # draw mouse
    if @attractor.isEnabled
      @fill 0, 255, 0
      @circle this.mouseX, this.mouseY, 7
