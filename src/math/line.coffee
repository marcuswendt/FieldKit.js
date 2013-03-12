###
  A simple line from multiple segments, can be sampled at any point.
  NOTE this curve does not always run through all given points.
  Work with any object type as long as it has x and y number properties.
###
class Polyline
  constructor: (@points=[]) ->

  add: (point) -> points.push point
  size: -> points.length
  clear: -> points = []

  point: (time) ->
    # first point
    if time <= 0
      points[0]

      # last point
    else if time >= 1
      points[points.length - 1]

      # in between
    else
      median = time * (points.length - 1)
      prev = points[Math.floor(median)]
      next = points[Math.ceil(median)]
      x: prev.x + (next.x - prev.x) * 0.5
      y: prev.y + (next.y - prev.y) * 0.5


###
A Catmull-Rom spline (which is a special form of the cubic hermite curve) implementation,
generates a smooth curve/interpolation from a number of Vec2 points.
###
class Spline
  first = second = beforeLast = last = undefined;

  points: []
  needsUpdate: false

  constructor: (@points = []) ->
    @needsUpdate = @points.length > 0

  add: (point) ->
    @points.push point
    @needsUpdate = true

  size: -> @points.length
  clear: -> @points = []

  update: ->
    return if @points.length < 4

    first = @points[0]
    second = @points[1]
    beforeLast = @points[@points.length - 2]
    last = @points[@points.length - 1]

    @needsUpdate = false

  point: (time) ->
    return if @points.length < 4

    # first point
    if time <= 0
      @points[0]

    # last point
    else if time >= 1
      @points[@points.length - 1]

    # in between
    else
      update() if @needsUpdate
      size = @points.length
      partPercentage = 1.0 / (size - 1)
      timeBetween = time / partPercentage
      i = Math.floor(timeBetween)
      normalizedTime = timeBetween - i
      t = normalizedTime * 0.5
      t2 = t * normalizedTime
      t3 = t2 * normalizedTime
      tmp1 = undefined
      if --i is -1
        # var tmp0 = second.sub_(first).normalizeTo(Number.MIN_VALUE);
        # tmp1 = first.sub_(tmp0);
        tmp1 = first.clone()
      else
        tmp1 = @points[i].clone()
      tmp2 = @points[++i].clone()
      tmp3 = @points[++i].clone()
      tmp4 = undefined
      if ++i is size

        # var tmp0 = beforeLast.sub_(last).normalizeTo(Number.MIN_VALUE);
        # tmp4 = last.sub_(tmp0);
        tmp4 = last.clone()
      else
        tmp4 = @points[i].clone()

      # calculate point
      tmp1.scale -t3 + 2 * t2 - t
      result = tmp1
      tmp2.scale 3 * t3 - 5 * t2 + 1
      result.add tmp2
      tmp3.scale -3 * t3 + 4 * t2 + t
      result.add tmp3
      tmp4.scale t3 - t2
      result.add tmp4
      result


module.exports =
  Polyline: Polyline
  Spline: Spline