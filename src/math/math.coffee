randomPkg = require './random'

random = new randomPkg.Random()

# fits the given value between min and max
fit01 = (value, min, max) -> value * (max - min) + min

module.exports =
  fit01: fit01
  randF: (min, max) -> random.float(min, max)
  randI: (min, max) -> random.int(min, max)