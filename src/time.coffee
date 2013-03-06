

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
    constructor: (beatsPerMinute=120, @sigNum=4, @sigDenom=4) ->
        @bpm = beatsPerMinute
        @timer = new Timer()
        @reset()

    reset: ->
        @timer.reset()

        @beat = @beatAbsolute = @bar = 0
        @prevBeat = -1
        @onBeat = @onBar = false

        @beatsPerMilliSecond = 1000 / (@bpm / 60)

    update: ->
        time = @timer.elapsed()

        @beatAbsolute = Math.floor(time / @beatsPerMilliSecond)

        if @beatAbsolute != @prevBeat
            @prevBeat = @beatAbsolute

            @beat = @beatAbsolute % @sigDenom + 1
            @bar = @beatAbsolute / @sigDenom + 1

            @onBeat = true
            @onBar = @beat == @sigNum
        else
            @onBeat = @onBar = false

        # console.log "time #{time} / beat #{@beatAbsolute} / on beat #{@onBeat} "
        @beatAbsolute


module.exports =
    Timer: Timer
    Tempo: Tempo