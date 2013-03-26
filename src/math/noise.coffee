simplex = require './simplex'

###

  Multi Noise Genrator Class

###
class Noise
  generator = null

  constructor: (random) ->
    @random = if random? then random else Math
    generator = new Simplex

  noise2: (x, y) -> generator.noise2 x, y
  noise3: (x, y, z) -> generator.noise3 x, y, z
  noise4: (x, y, z, w) -> generator.noise4 x, y, z, w

module.exports.Noise = Noise