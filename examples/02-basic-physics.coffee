class Example extends fk.client.Sketch
  Vec2 = fk.math.Vec2

  setup: ->
#    console.log "w #{@width} h #{@height}"

    @physics = new fk.physics.Physics()

    # use 2D particles
    @physics.emitter.type = fk.physics.Particle2

    @physics.emitter.max = 1000

    # randomize birth position
    @physics.emitter.init = (particle) =>
      particle.setPosition2 Math.random() * @width, Math.random() * @height

    # creates a force that slowly pulls particles up
    @physics.add new fk.physics.Force new Vec2(0, -1), 0.025

    # makes sure our particles never leave the canvas
    @physics.add new fk.physics.Wrap2 new Vec2(), new Vec2(@width, @height)

    @attractor = new fk.physics.Attractor new Vec2(), 150, 0.5
    @physics.add @attractor


  draw: ->
    @attractor.target.set2 @mouseX, @mouseY
    @physics.update()

    # draw
    # @fill()
    @background(0)

    @fill(255)
    for particle in @physics.particles
      @rect particle.position.x, particle.position.y, 3, 3

    @fill 255, 0, 255
    @rect this.mouseX, this.mouseY, 5, 5
