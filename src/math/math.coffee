randomPkg = require './random'

random = new randomPkg.Random()

module.exports =

  # remaps the given value from a given incoming range onto the given output range
  fit: (value, inMin, inMax, outMin, outMax) ->
    value = Math.max(inMin, Math.min(inMax, value)) # clamp value before fitting
    ((value - inMin) / (inMax - inMin)) * (outMax - outMin) + outMin

  # fits the given value between min and max
  fit01: (value, min, max) -> value * (max - min) + min

  # makes sure the given value doesnt exceed min or max
  clamp: (value, min, max) -> Math.max(min, Math.min(max, value))
  clamp01: (value) -> Math.max(0, Math.min(1, value))

  randf: (min, max) -> random.randf(min, max)
  randi: (min, max) -> random.randi(min, max)
  flipCoin: (chance) -> random.flipCoin(chance)

  # rounds the given number to a certain number of decimals
  round: (value, decimals=0) ->
    if decimals == 0
      Math.round(value)
    else
      exp = Math.pow(10, decimals);
      Math.round(value * exp) / exp;

  interpolate:
    #! see http://en.wikipedia.org/wiki/Slerp
    spherical: (current, target, delta) -> current * (1.0 - delta) + target * delta

    linear: (current, target, delta) -> current + (target - current) * delta

  ###
    Easing Functions - inspired by http://easings.net
    only considering the t value for the range [0, 1] => [0, 1]
  ###
  ease:
    linear: (t) -> t

    # accelerating from zero velocity
    inQuad: (t) -> Math.pow t, 2

    # decelerating to zero velocity
    outQuad: (t) -> -(Math.pow((t - 1), 2) - 1)

    # acceleration until halfway, then deceleration
    inOutQuad: (t) ->
      return 0.5 * Math.pow(t, 2)  if (t /= 0.5) < 1
      -0.5 * ((t -= 2) * t - 2)

    inCubic: (t) -> Math.pow t, 3

    outCubic: (t) -> Math.pow((t - 1), 3) + 1

    inOutCubic: (t) ->
      return 0.5 * Math.pow(t, 3)  if (t /= 0.5) < 1
      0.5 * (Math.pow((t - 2), 3) + 2)

    inQuart: (t) -> Math.pow t, 4

    outQuart: (t) -> -(Math.pow((t - 1), 4) - 1)

    inOutQuart: (t) ->
      return 0.5 * Math.pow(t, 4)  if (t /= 0.5) < 1
      -0.5 * ((t -= 2) * Math.pow(t, 3) - 2)

    inQuint: (t) -> Math.pow t, 5

    outQuint: (t) -> Math.pow((t - 1), 5) + 1

    inOutQuint: (t) ->
      return 0.5 * Math.pow(t, 5)  if (t /= 0.5) < 1
      0.5 * (Math.pow((t - 2), 5) + 2)

    inSine: (t) -> -Math.cos(t * (Math.PI / 2)) + 1

    outSine: (t) -> Math.sin t * (Math.PI / 2)

    inOutSine: (t) -> -0.5 * (Math.cos(Math.PI * t) - 1)

    inExpo: (t) -> (if (t is 0) then 0 else Math.pow(2, 10 * (t - 1)))

    outExpo: (t) -> (if (t is 1) then 1 else -Math.pow(2, -10 * t) + 1)

    inOutExpo: (t) ->
      return 0 if t == 0
      return 1 if t == 1
      return 0.5 * Math.pow(2, 10 * (t - 1))  if (t /= 0.5) < 1
      0.5 * (-Math.pow(2, -10 * --t) + 2)

    inCirc: (t) -> -(Math.sqrt(1 - (t * t)) - 1)

    outCirc: (t) -> Math.sqrt 1 - Math.pow((t - 1), 2)

    inOutCirc: (t) ->
      return -0.5 * (Math.sqrt(1 - t * t) - 1)  if (t /= 0.5) < 1
      0.5 * (Math.sqrt(1 - (t -= 2) * t) + 1)

    outBounce: (t) ->
      if (t) < (1 / 2.75)
        7.5625 * t * t
      else if t < (2 / 2.75)
        7.5625 * (t -= (1.5 / 2.75)) * t + 0.75
      else if t < (2.5 / 2.75)
        7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375
      else
        7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375

    inBack: (t) ->
      s = 1.70158
      (t) * t * ((s + 1) * t - s)

    outBack: (t) ->
      s = 1.70158
      (t = t - 1) * t * ((s + 1) * t + s) + 1

    inOutBack: (t) ->
      s = 1.70158
      return 0.5 * (t * t * (((s *= (1.525)) + 1) * t - s))  if (t /= 0.5) < 1
      0.5 * ((t -= 2) * t * (((s *= (1.525)) + 1) * t + s) + 2)

    elastic: (t) ->
      -1 * Math.pow(4, -8 * t) * Math.sin((t * 6 - 1) * (2 * Math.PI) / 2) + 1

    swingFromTo: (t) ->
      s = 1.70158
      (if ((t /= 0.5) < 1) then 0.5 * (t * t * (((s *= (1.525)) + 1) * t - s)) else 0.5 * ((t -= 2) * t * (((s *= (1.525)) + 1) * t + s) + 2))

    swingFrom: (t) ->
      s = 1.70158
      t * t * ((s + 1) * t - s)

    swingTo: (t) ->
      s = 1.70158
      (t -= 1) * t * ((s + 1) * t + s) + 1

    bounce: (t) ->
      if t < (1 / 2.75)
        7.5625 * t * t
      else if t < (2 / 2.75)
        7.5625 * (t -= (1.5 / 2.75)) * t + 0.75
      else if t < (2.5 / 2.75)
        7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375
      else
        7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375

    bouncePast: (t) ->
      if t < (1 / 2.75)
        7.5625 * t * t
      else if t < (2 / 2.75)
        2 - (7.5625 * (t -= (1.5 / 2.75)) * t + 0.75)
      else if t < (2.5 / 2.75)
        2 - (7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375)
      else
        2 - (7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375)

    fromTo: (t) ->
      return 0.5 * Math.pow(t, 4)  if (t /= 0.5) < 1
      -0.5 * ((t -= 2) * Math.pow(t, 3) - 2)

    from: (t) -> Math.pow t, 4

    to: (t) -> Math.pow t, 0.25
