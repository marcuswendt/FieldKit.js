###
      _____  __  _____  __     ____
     / ___/ / / /____/ / /    /    \   FieldKit
    / ___/ /_/ /____/ / /__  /  /  /   (c) 2013, FIELD. All rights reserved.
   /_/        /____/ /____/ /_____/    http://www.field.io

   Created by Marcus Wendt on 07/03/2013

###

util = require './core/util'

extend = ->
  switch arguments.length
    when 1
      util.extend fk, arguments[0]

    when 2
      pkg = arguments[0]
      fk[pkg] = {} if not fk[pkg]?
      util.extend fk[pkg], arguments[1]


# Namespace
fk = {}


#
# Core Library
#
extend require './core/color'
extend require './core/time'

# Math
extend require './core/math/random'
extend require './core/math/vector'

# Utilities
extend 'util', util


#
# Independent Sub Libraries
#
extend 'physics', require './physics/physics'
extend 'physics', require './physics/particle'
extend 'physics', require './physics/behaviours'
extend 'physics', require './physics/constraints'


# client/browser specific libraries
extend 'client', require './client/sketch'


#
# Exports
#
module.exports = fk

global.fk = fk


