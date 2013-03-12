###

  FIELDKIT SKETCH CLASS

####
class Sketch
  width: -1
  height: -1
  domObjectId: "container"

  # drawing
  g: null

  # events
  mouseX: 0
  mouseY: 0

  constructor: (options) ->
    # initialise drawing context
    domObject = document.getElementById(@domObjectId)

    @width = domObject.offsetWidth if @width == -1
    @height = domObject.offsetHeight if @height == -1

    # create 2D canvas
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

  isRunning = false

  start: ->
    isRunning = true

    # set up draw loop
    render = =>
      @draw()
      if(isRunning)
        window.requestAnimationFrame render

    window.requestAnimationFrame render

  stop: -> isRunning = false

  toString: -> "Sketch"


  ###
    Sketch API
  ###
  setup: ->
  draw: ->


  ###
    2D Drawing API
  ###
  isFillEnabled = true
  isStrokeEnabled = false

  computeStyle = (args) ->
    switch args.length
      # Grey
      when 1
        grey = args[0]
        "rgba(#{grey}, #{grey}, #{grey}, 1)"

      # Grey + Alpha
      when 2
        grey = args[0]
        "rgba(#{grey}, #{grey}, #{grey}, #{args[1]})"

      # RGB
      when 3
        "rgba(#{args[0]}, #{args[1]}, #{args[2]}, 1)"

      # RGBA
      when 4
        "rgba(#{args[0]}, #{args[1]}, #{args[2]}, #{args[3]})"

      else
        "#FF0000"

  # multiple arguments: see computeStyle
  background: ->
    @g.clearRect 0, 0, @width, @height
    style = @g.fillStyle
    @g.fillStyle = computeStyle(arguments)
    @g.fillRect 0, 0, @width, @height
    @g.fillStyle = style

  # multiple arguments: see computeStyle
  fill: ->
    isFillEnabled = true
    @g.fillStyle = computeStyle(arguments)

  # multiple arguments: see computeStyle
  stroke: ->
    isStrokeEnabled = true
    @g.strokeStyle = computeStyle(arguments)

  noFill: -> isFillEnabled = false

  noStroke: -> isStrokeEnabled = false

  rect: (x, y, w, h) ->
    @g.fillRect x, y, w, h  if isFillEnabled
    @g.strokeRect x, y, w, h  if isStrokeEnabled


module.exports =
  Sketch: Sketch