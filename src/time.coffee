

# keeps track of time, measures intervals etc.
class Timer
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
    # define the tempo using a pace in BPM and a time signature
    constructor: (beatsPerMinute=120, @sigNum=4, @sigDenom=4) ->
        @bpm = beatsPerMinute

        # smallest unit in the temporal grid, how often to update in 1/n bars
        @resolution = 32
        
        @reset()

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
        @beat = @bar = 0

        # booleans wether the current timestep is on that particular note
        @onBeat = @onBar = false
        @on32 = @on16 = @on8 = @on4 = @on2 = false
       


    # call update continously
    update: (dt) ->
        @time += dt

        if @time - @prevEvent >= @gridInterval
            @prevEvent = @time

            gridUnits = Math.floor @time / @gridInterval

            u = gridUnits
            r = @resolution

            @beats = Math.floor @time / @beatInterval
            @beat = @beats % @sigNum

            @onBeat = u % (r / @sigNum) == 0
            @onBar = u % 

            @on32 = u % (r / 32) == 0
            @on16 = u % (r / 16) == 0
            @on8 = u % (r / 8) == 0
            @on4 = u % (r / 4) == 0
            @on2 = u % (r / 2) == 0

            # console.log "time #{@time} beat #{@beat} / 32: #{@on32} 16: #{@on16} / 8: #{@on8}"

        else
            @onBeat = @onBar = false
            @on32 = @on16 = @on8 = @on4 = @on2 = false

        @beat


module.exports =
    Timer: Timer
    Tempo: Tempo