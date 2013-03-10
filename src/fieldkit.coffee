# 
# FieldKit
# 

util = require './util'


# Namespace
fk = {}

# Utility method to merge a files module exports into the main fk namespace
merge = (file) ->
  console.log "loading #{file}"
  module = require file
  fk = util.util.extend fk, module


#
# Core Library
#

# Math
merge './math/vector'
merge './math/random'


# Misc
merge './color'
merge './time'

merge './util'

module.exports = exports = fk
