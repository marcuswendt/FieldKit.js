# 
# FieldKit Index
# 
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
