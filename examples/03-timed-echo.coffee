class Example extends fk.client.Sketch
  Vec2 = fk.math.Vec2
  State = fk.physics.State

  rng = new fk.math.Random()

  cMouse = 0

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

    # randomize birth position
    @physics.emitter.init = (particle) =>
      particle.setPosition2 @width / 2, ((Math.random() * 2 - 1) * 0.25 + 0.5) * @height
      particle.force.set2 (Math.random() * 2 - 1) * 10.1, 0

      particle.lifetime = rng.int 60, 120
      particle.size = 5

    #      particle.setPosition2 Math.random() * @width, Math.random() * @height

    # creates a force that slowly pulls particles up
    @physics.add new fk.physics.Force new Vec2(0, 1), 0.001

    # makes sure our particles never leave the canvas
    @physics.add new fk.physics.Wrap2 new Vec2(), new Vec2(@width, @height)

    @attractor = new fk.physics.Attractor new Vec2(), 150, 0.5
#    @physics.add @attractor

    # -- Graphics --
    cMouse = @color 255, 0, 255


  draw: ->

    dt = @timer.update()
    beat = @tempo.update dt

    #    console.log "bar: #{@tempo.bar} beat: #{@tempo.beat}"

    if @tempo.onBar and @tempo.bar % 5 == 0
      console.log "beep"
      @physics.emitter.rate = 250
    else
      @physics.emitter.rate = 0

    @attractor.target.set2 @mouseX, @mouseY

    # update physics
    @physics.update()

    # draw
    @background(0)

#    @fill(255)
    for particle in @physics.particles
      if particle.state == State.ALIVE
        life = 1 - (particle.age / particle.lifetime)
        @fill 255, life
        @rect particle.position.x, particle.position.y, particle.size, particle.size

    @fill cMouse
    @rect this.mouseX, this.mouseY, 5, 5
