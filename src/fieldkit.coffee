###
      _____  __  _____  __     ____
     / ___/ / / /____/ / /    /    \   FieldKit
    / ___/ /_/ /____/ / /__  /  /  /   (c) 2013, FIELD. All rights reserved.
   /_/        /____/ /____/ /_____/    http://www.field.io

   Created by Marcus Wendt on 07/03/2013

###

util = require './util'

# Namespace
fk =
  # Merges the given source file or module into the main fk namespace
  module: (source) ->
    module = if typeof source == 'string' then require source else source
    util.extend this, module

  # Stores the given module in a named subpackage
  package: (name, module) ->
    @[name] = module


#
# Core Library
#

# Math
fk.module './math/vector'
fk.module './math/random'

# Misc
fk.module './color'
fk.module './time'

fk.package 'util', util

module.exports = exports = fk
