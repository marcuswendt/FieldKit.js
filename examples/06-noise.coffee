###

  Noise Generator

###
class Example extends fk.client.Sketch

  setup: ->
    rng = new fk.math.Random()
    @noise = new fk.math.Noise(rng)
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

        n = @noise.noise2 xn, yn
#        n = (xn + yn) % 1
        n *= 256
        image.setPixel x, y, n, n, n

#        image.setPixel x, y, 255, 0, 0, 255

    image