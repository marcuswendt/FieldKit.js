
$(document).ready ->
  defaultExample = 0
  pageTitle = "FieldKit.js"

  historyState = {}
  currentExample = null

  loadExample = (title, url) ->
    console.log "loading example '#{title}' (#{url})"

    # stop previous sketch
    if window.currentExample
      window.currentExample.stop()

    # update page
    $("#title").text "#{pageTitle}: #{title}"
    $("#container").html "<p><i>loading...</i></p>"

    $("#code").hide()
    $("#code").text ""

    # load script
    $.get url, (data) ->

      # update page
      $("#container").html ""
      $("#code").html "<pre>#{data}</pre>"

      # compile CoffeeScript to JavaScript
      source = data + "\n" + "window.currentExample = new Example()"
      js = CoffeeScript.compile source

      # execute script
      $.globalEval js

      # update browser history
      slug = url.replace ".coffee", ""
      window.history.pushState { title: title, url: url }, title, "##{slug}"

  $('#showCode').click -> $("#code").fadeToggle()

  # handle history back/forward changes
  $(window).bind 'popstate', (e) ->
    state = e.originalEvent.state
    loadExample state.title, state.url if state?

  # initialise menu
  $.getJSON '../index.json', (data) ->
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
