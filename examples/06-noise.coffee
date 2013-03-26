###

  Noise Generator

###
class Example extends fk.client.Sketch

  setup: ->
    rng = new fk.math.Random()
    @noise = new fk.math.SimplexNoise(rng)
    @image = @renderNoiseTexture @width, @height

  draw: ->
    @background(0)
    @drawImage @image, 0, 0

  renderNoiseTexture: (width, height) ->
    image = @createImage width, height

    for y in [0...height]
      for x in [0...width]
        freq = 10
        xn = x / width * freq
        yn = y / height * freq

        value = @noise.noise3(xn, yn, (xn + yn) * 5)
        n = value * 256

        image.setPixel x, y, n, n, n

    image