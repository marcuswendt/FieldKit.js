Color = require('../color').Color
Vec2 = require('../math/vector').Vec2


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
    domObject.onmousemove = (e) =>
      @mouseX = e.x
      @mouseY = e.y

    domObject.onmousedown = (e) => @mouseDown()
    domObject.onmouseup = (e) => @mouseUp()

  isRunning: false

  start: ->
    @isRunning = true

    # set up draw loop
    render = =>
      @draw()
      if(@isRunning)
        window.requestAnimationFrame render

    window.requestAnimationFrame render

  stop: -> @isRunning = false

  toString: -> "Sketch"


  ###
    Sketch API
  ###
  setup: ->
  draw: ->

  mouseDown: ->
  mouseUp: ->


  ###
    2D Drawing API
  ###
  isFillEnabled = true
  isStrokeEnabled = false

  computeStyle = (args) ->
    switch args.length
      # Fillstyle / Grey
      when 1
        arg = args[0]

        # argument is a fillstyle
        if typeof arg == "string"
          arg

        # assumes object is a fk.Color
        else if arg instanceof Color
          "rgba(#{arg.r * 255}, #{arg.g * 255}, #{arg.b * 255}, #{arg.a})"

        # argument is a greyscale value 0-255
        else
          "rgba(#{arg}, #{arg}, #{arg}, 1)"

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

  color: -> computeStyle(arguments)

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

  lineWidth: (width) -> @g.lineWidth = width

  noFill: -> isFillEnabled = false

  noStroke: -> isStrokeEnabled = false

  rect: (x, y, w, h) ->
    @g.fillRect x, y, w, h  if isFillEnabled
    @g.strokeRect x, y, w, h  if isStrokeEnabled

  circle: (x, y, r) ->
    @g.beginPath()
    @g.arc x, y, r, 0, 360
    @g.fill() if isFillEnabled
    @g.stroke() if isStrokeEnabled
    @g.closePath()

  line: (x1, y1, x2, y2) ->
    @g.beginPath()

    # line using Vec2s
    if x1 instanceof Vec2
      @g.moveTo x1.x, x1.y
      @g.lineTo y1.x, y1.y

    # line using Numbersx
    else
      @g.moveTo x1, y1
      @g.lineTo x2, y2

    @g.stroke()
    @g.closePath()

module.exports =
  Sketch: Sketch