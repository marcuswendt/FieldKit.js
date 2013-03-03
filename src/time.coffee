

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



# keeps track of time, converts between beats, bars, time, tempo etc
class Tempo


module.exports =
    Timer: Timer
    Tempo: Tempo