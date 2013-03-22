

# keeps track of time, measures intervals etc.
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


# keeps track of rhythm, converts between beats, bars, time, tempo etc
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


module.exports =
  Timer: Timer
  Tempo: Tempo