###
  Particle Noise Trails
###
class Example extends fk.client.Sketch

  trails: null

  setup: ->
    rng = new fk.math.Random()
    noise = new fk.math.SimplexNoise(rng)
    density = fk.math.randi 20, 50
    @trails = @renderVelocityTrails density, noise, 200
    console.log "trails: #{@trails.length} points: #{@trails[0].points.length}"

  #    rng = new fk.math.Random()
  #    @noise = new fk.math.SimplexNoise(rng)
  #    @image = @renderNoiseTexture @width, @height
  #    @drawImage @image, 0, 0

  draw: ->
    @background(0)

    @noFill()
    for t in @trails
      @stroke t.color * 255 | 0
      @polygon t.points


  renderVelocityTrails: (step, noise, length) ->
    # setup physics
    class Trail extends fk.physics.Particle2
      color: 1
      points: []

      initTrail: ->
        @color = fk.math.randf(0.1, 1)
        @points = []

      updateTrail: ->
        @points.push @position.clone()

    physics = new fk.physics.Physics()
    physics.emitter.type = Trail
    physics.emitter.rate = 0


    # Behaviours
    class NoiseAdvector extends fk.physics.Behaviour
      tmp = new fk.math.Vec2()

      apply: (particle) ->
        p = particle.position
        # tmp.set2 noise.noise3(p.x, p.y, particle.age), noise.noise3(p.x + 53, p.y + particle.id, particle.age - particle.id)
        tmp.set2 noise.noise2(p.x, p.y), noise.noise2(p.x + particle.age, p.y + particle.id)

        particle.force.add tmp
#        particle.position.add tmp

      toString: -> "NoiseAdvector"

    physics.add new NoiseAdvector()

    # Emit particles on a grid
    sx = @width / step | 0
    sy = @height / step | 0

    ox = sx / 2
    oy = sy / 2

    for y in [0..sy]
      for x in [0..sx]
        p = physics.emitter.create()
        p.setPosition2 x * step + ox, y * step + oy
        p.initTrail()

    # Integrate
    for f in [0..length]
      physics.update()
      for p in physics.particles
        p.updateTrail()

    physics.particles


#  renderNoiseTexture: (width, height) ->
#    image = @createImage width, height
#
#    for y in [0...height]
#      for x in [0...width]
#        freq = 10
#        xn = x / width * freq
#        yn = y / height * freq
#
#        value = @noise.noise3(xn, yn, (xn + yn) * 5)
#        n = value * 256
#
#        image.setPixel x, y, n, n, n
#
#    image