class Example extends fk.client.Sketch
  setup: ->

  draw: ->
    @background(0)
    @fill 255
    @rect this.mouseX, this.mouseY, 5, 5
