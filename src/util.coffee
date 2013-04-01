#
# JavaScript Language Utility Methods
#
util = {}

util.extend = (obj, source) ->
  # ECMAScript5 compatibility based on: http://www.nczonline.net/blog/2012/12/11/are-your-mixins-ecmascript-5-compatible/
  if Object.keys
    keys = Object.keys(source)
    i = 0
    il = keys.length

    while i < il
      prop = keys[i]
      Object.defineProperty obj, prop, Object.getOwnPropertyDescriptor(source, prop)
      i++
  else
    safeHasOwnProperty = {}.hasOwnProperty
    for prop of source
      obj[prop] = source[prop]  if safeHasOwnProperty.call(source, prop)
  obj


# removes the element from the given list (if it exists) and returns the list
util.removeElement = (element, list) ->
  index = list.indexOf element
  list.splice index, 1 unless index is -1
  list


# shuffles the order of the given object or array
# optionally takes a random number generator object
# returns the shuffled object
util.shuffle = (object, rng) ->
  rng = Math unless rng?
  i = object.length
  while i
    j = parseInt(rng.random() * i)
    x = object[--i]
    object[i] = object[j]
    object[j] = x
  object



###

  JavaScript getter and setter support for CoffeeScript classes
  Ref: https://github.com/jashkenas/coffee-script/issues/1039

  Note:
  Classes using this wont work under IE6 + IE7

  Usage:
  class Vector3D extends EXObject
    constructor: (@x, @y, @z) ->

    @get 'x', -> @[0]
    @get 'y', -> @[1]
    @get 'z', -> @[2]

    @set 'x', (x) -> @[0] = x
    @set 'y', (y) -> @[1] = y
    @set 'z', (z) -> @[2] = z

###
util.EXObject = class EXObject

  @get: (propertyName, func) ->
    Object.defineProperty @::, propertyName,
      configurable: true
      enumerable: true
      get: func

  @set: (propertyName, func) ->
    Object.defineProperty @::, propertyName,
      configurable: true
      enumerable: true
      set: func


module.exports = util