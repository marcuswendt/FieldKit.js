
$(document).ready ->
  defaultExample = 0
  pageTitle = "FieldKit.js"

  historyState = {}
  currentExample = null
  currentEditor = null

  loadExample = (title, url) ->
    console.log "loading example '#{title}' (#{url})"

    # stop previous sketch
    if window.currentExample
      window.currentExample.stop()

    # update page
    $("#title").text "#{pageTitle}: #{title}"
    $("#container").html "<p><i>loading...</i></p>"

    $("#code").hide()
#    $("#code").text ""

    # load script
    $.get url, (data) ->

      # update page
      $("#container").html ""

      currentEditor = CodeMirror document.getElementById("code"), {
        value: data
        mode: "coffeescript"
        theme: "eclipse"
        runable: true
      }

      # compile CoffeeScript to JavaScript
      source = data + "\n" + "window.currentExample = new Example()"
      js = CoffeeScript.compile source

      # execute script
      $.globalEval js

      # update browser history
      slug = url.replace ".coffee", ""
      window.history.pushState { title: title, url: url }, title, "##{slug}"

  #
  # Events
  #
  $('#showCode').click ->
    $("#code").fadeToggle(120)
    if currentEditor?
      currentEditor.setSize($('#code').width(), $('#code').height())

  # handle history back/forward changes
  $(window).bind 'popstate', (e) ->
    state = e.originalEvent.state
    loadExample state.title, state.url if state?


  #
  # Menu
  #
  $.getJSON './index.json', (data) ->
    menu = $('#menu')

    for example in data.examples
#      console.log example
      item = "<option value=\"#{example.url}\">#{example.title}</option>"
      menu.append item

    menu.change (e) ->
      selected = $("option:selected", menu)[0]
      loadExample selected.label, selected.value

    # load default example
    example = data.examples[defaultExample]

    url = window.location.href
    if url.indexOf("#") != -1
      anchor = url.slice(url.indexOf("#") + 1)
      sourceUrl = "#{anchor}.coffee"

      for example2 in data.examples
        if example2.url == sourceUrl
          example = example2

    loadExample example.title, example.url
