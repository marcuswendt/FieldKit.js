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
  module: (module) ->
    util.extend this, module

  # Stores the given module in a named subpackage
  package: (name, module) ->
    @[name] = module


#
# Core Library
#

# Math
fk.module require './math/vector'
fk.module require './math/random'

# Misc
fk.module require './color'
fk.module require './time'

fk.package 'util', util

module.exports = fk
