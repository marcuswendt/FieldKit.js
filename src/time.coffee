util = require './util'
math = require './math/math'

###
  Timer: keeps track of time, measures intervals etc.
  ------------------------------------------------------------------------------
###
class Timer
  now: null
  prev: null

  constructor: ->
    @reset()

  update: ->
    @now = Date.now()
    dt = @now - @prev
    @prev = @now
    dt

  elapsed: -> Date.now() - @prev

  reset: -> @now = @prev = Date.now()


###
  Tempo: keeps track of rhythm, converts between beats, bars, time, tempo etc
  ------------------------------------------------------------------------------
###
class Tempo
  bpm: 120
  sigNum: 4
  sigDenom: 4

  # smallest unit in the temporal grid, how often to update in 1/n bars
  resolution: 32

  # internal - all times in milliseconds
  beatInterval: 0
  gridInterval: 0
  time: 0
  prevEvent: 0

  # accessors - overriden by every update
  beats: 0
  bars: 0

  beat: 0

  onBeat: false
  onBar: false
  on64: false
  on32: false
  on16: false
  on8: false
  on4: false
  on2: false

  # define the tempo using a pace in BPM and a time signature
  constructor: (@bpm=120, @sigNum=4, @sigDenom=4, @resolution=32) ->
    @reset()

  # when changing the tempo (bpm, signature) or resolution - reset needs to be called
  reset: ->
    # beats per millisecond
    @beatInterval = 1000 / (@bpm / 60)

    # user-specified grid units per millisecond
    @gridInterval = @beatInterval * @sigNum / @resolution

    # reset properties
    @time = @prevEvent = 0

    # absolute number of beats so far
    @beats = 0

    # current beat within a bar
    @beat = @bars = 0

    # booleans wether the current timestep is on that particular note
    @onBeat = @onBar = false
    @on64 = @on32 = @on16 = @on8 = @on4 = @on2 = false


  # call update continously with time in milliseconds since last timestep
  update: (dt) ->
    forceOnGrid = @time - @prevEvent >= @gridInterval
    @setTime @time + dt, forceOnGrid
    @beat

  # sets the internal clock to an absolute time in seconds
  setTime: (time, forceOnGrid) ->
    @time = time

    # time is on grid
    if @time % @gridInterval == 0 or forceOnGrid
      @prevEvent = time

      gridUnits = Math.floor @time / @gridInterval

      u = gridUnits
      r = @resolution

      @beats = Math.floor @time / @beatInterval
      @bars = Math.floor @beats / @sigDenom

      @beat = @beats % @sigNum

      @onBeat = u % (r / @sigNum) == 0
      @onBar = (u % @resolution) == 0

      @on64 = u % (r / 64) == 0
      @on32 = u % (r / 32) == 0
      @on16 = u % (r / 16) == 0
      @on8 = u % (r / 8) == 0
      @on4 = u % (r / 4) == 0
      @on2 = u % (r / 2) == 0

    # time is not on grid
    else
      @onBeat = @onBar = false
      @on64 = @on32 = @on16 = @on8 = @on4 = @on2 = false

    @beat


###
  Time: Represents a single moment in time
  ------------------------------------------------------------------------------
###
class Time
  value: 0 # time in milliseconds

  # creates a new Time object from either
  # - number of milliseconds
  # - a time-arithmetic string (using the given fps and tempo)
  # - another Time object's value
  constructor: (arg=0, fps, tempo) ->
    @value = switch typeof(arg)
      when 'number' then arg
      when 'string' then @eval(arg, fps, tempo)
      else arg.value

  # adds the given time object or millisecond value
  add: (time) -> @value += if typeof(time) == 'number' then time else time.value

  # adds the given time object or millisecond value and returns the result as new object
  add_: (time) -> new Time(@value + if typeof(time) == 'number' then time else time.value)

  # subtrct the given time object or millisecond value
  sub: (time) -> @time -= if typeof(time) == 'number' then time else time.value

  # subtracts the given time object or millisecond value and returns the result as new object
  sub_: (time) -> new Time(@value - if typeof(time) == 'number' then time else time.value)

  scale: (factor) -> @value *= factor
  scale_: (factor) -> new Time(@value * factor)

  clone: -> new Time(@value)
  equals: (time) -> @value == if typeof(time) == 'number' then time else time.value
  toString: -> "#{@value}ms"

  # Returns its position relative to the given Timespan.
  normalizedTo: (span) -> math.fit(@value, span.from.value, span.to.value, 0, 1)

  toFrame: (fps=60) -> Math.round(@value / (1000 / fps))

  eval: (string, fps, tempo=null) ->
    # init time unit conversions
    units = [
      { symbol: 's', factor: 1000 },
      { symbol: 'f', factor: 1000 / fps }
    ]

    if tempo?
      units.push { symbol: 'i', factor: tempo.gridInterval }
      units.push { symbol: 'bar', factor: tempo.gridInterval * grid.resolution }

    # apply all unit conversions
    for unit in units
      re = new RegExp "\\d+(?=#{unit.symbol})", "g"
      string = string.replace re, (value) -> value * unit.factor

    # strip all alphabetical characters of string
    string = string.replace /[A-Za-z$-]/g, ''

    # evaluate arithmetic string
    eval(string)

  # creates a new Time object from the given number of seconds
  @s: (seconds) -> new Time seconds * 1000

  # creates a new Time object from the given number of milliseconds
  @ms: (milliseconds) -> new Time milliseconds

  # creates a new Time object from the given number of frames at a certain framerate
  @f: (frame, fps) -> new Time frame / (1000 / fps)

  # creates a new Time object from the given number of Tempo grid intervals
  @i: (intervals, tempo) -> new Time intervals * tempo.gridInterval

  # creates a new Time object from the given time-arithmetic string
  @str: (string, fps, tempo) -> new Time string, fps, tempo



###
  Timespan: Represents a duration of time between two moments
  ------------------------------------------------------------------------------
###
class Timespan extends util.EXObject
  constructor: ->
    switch arguments.length
      when 0
        @from = new Time(0)
        @to = new Time(0)

      when 1
        @from = new Time(0)
        @to = new Time(arguments[0])

      when 2
        @from = new Time(arguments[0])
        @to = new Time(arguments[1])

  # returns a list of Time events by stepping through this timespan along a given interval
  # interval can be another time object or millisecond value
  segmentByInterval: (interval, snapEnd=false) ->
    interval = if typeof interval == 'number' then new Time(interval) else interval

    segments = []
    current = new Timespan(@from, @from.add_(interval))
    segments.push current.clone()

    while current.to.value < @to.value
      current.from.add interval
      current.to.add interval
      segments.push current.clone()

    # creates another segment at the
    if snapEnd and segments.length > 0
      last = segments[ segments.length - 1 ]
      halfInterval = interval.scale_ 0.5
      if @to.value - last.to.value > halfInterval
        segments.push new Timespan(last.clone(), @to.clone())
      else
        last.to.value = @to.value

    segments

  # checks wether this timespan intersects with the given one
  overlaps: (other) ->
    from = @from.value
    to = @to.value
    from2 = other.from.value
    to2 = other.to.value

    (to2 >= from and to2 <= to) or
    (from2 >= from and from2 <= to) or
    (from2 <= from and to2 >= to)

  clone: -> new Timespan(@from, @to)
  toString: -> "Timespan(#{@from} - #{@to})"

  # sets the duration
  @set 'length', (length) -> @to.value = @from.value + length
  @get 'length', -> new Time(@to.value - @from.value)

  # return this duration in seconds
  @get 's', -> @length.s

  # factory methods
  @s: (seconds) -> new Timespan(seconds * 1000)


module.exports =
  Timer: Timer
  Tempo: Tempo

  Time: Time
  Timespan: Timespan