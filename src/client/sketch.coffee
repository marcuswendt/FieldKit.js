###

  FIELDKIT SKETCH CLASS

####
class Sketch
  width: 640
  height: 480
  domObjectId: "container"

  # drawing
  g: null

  # events
  mouseX: 0
  mouseY: 0

  constructor: (options) ->
    # initialise drawing context
    domObject = document.getElementById(@domObjectId)
    canvas = document.createElement("canvas")
    canvas.width = @width
    canvas.height = @height
    domObject.appendChild canvas
    @g = canvas.getContext("2d")

    # initialise sketch
    @setup()
    @start()

    # setup event listeners
    document.onmousemove = (e) =>
      @mouseX = e.x
      @mouseY = e.y

  start: ->
    # set up draw loop
    render = ->
      self.draw()
      window.requestAnimationFrame render

    window.requestAnimationFrame render

  toString: -> "Sketch"


  ###
    Sketch API
  ###
  setup: ->
  draw: ->


    ###
      2D Drawing API
    ###
  clear: ->
    @g.clearRect 0, 0, @width, @height

  fill: (color) ->
    @isFillEnabled = true
    @g.fillStyle = color

  stroke: (color) ->
    @isStrokeEnabled = true
    @g.strokeStyle = color

  noFill: -> @isFillEnabled = false

  noStroke: -> @isStrokeEnabled = false

  rect: (x, y, w, h) ->
    @g.fillRect x, y, w, h  if @isFillEnabled
    @g.strokeRect x, y, w, h  if @isStrokeEnabled


module.exports =
  Sketch: Sketch