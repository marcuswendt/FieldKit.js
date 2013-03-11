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
