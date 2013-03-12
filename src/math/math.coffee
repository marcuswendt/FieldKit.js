math =
  # fits the given value between min and max
  fit01: (value, min, max) -> value * (max - min) + min

  # returns a new random number between min and max
  rand: (min, max, rng) ->
    r = if rng? then rng.next() else Math.random()
    r * (max - min) + min


module.exports = math