#
# Work in Progress
#
fs = require 'fs'
{print} = require 'sys'
{spawn} = require 'child_process'


task 'clean', 'removes all compilation artefacts', ->


task 'build', 'compiles the CoffeeScript sources to JavaScript', ->
  coffee = spawn 'coffee', ['-c', '-o', 'lib', 'src']

  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()

  coffee.stdout.on 'data', (data) ->
    print data.toString()

  coffee.on 'exit', (code) ->
    callback?() if code is 0

task 'print', 'print the entire fieldkit package contents', ->
  invoke 'build'

  util = require 'util'
  fk = require './lib/fieldkit'
  console.log util.inspect fk


task 'examples', 'start static server for examples', ->
  port = 8080
  buildFile = '/build/fieldkit.js' 

  console.log "Launching example file server on localhost:#{port}"

  staticServer = require 'node-static'
  fileServer = new(staticServer.Server)('./', { cache: 0 })

  server = require('http').createServer (request, response) ->
    request.addListener 'end', ->
        fileServer.serve request, response, (e, res) ->
          if request.url == '/'
            response.writeHead 302, { 'Location': 'examples/' }
            response.end()

  server.listen port