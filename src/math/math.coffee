randomPkg = require './random'

random = new randomPkg.Random()

module.exports =
  # fits the given value between min and max
  fit01: (value, min, max) -> value * (max - min) + min

  clamp: (value, min, max) -> Math.max(min, Math.min(max, value))

  randF: (min, max) -> random.float(min, max)
  randI: (min, max) -> random.int(min, max)
  randB: (chance) -> random.bool(chance)
