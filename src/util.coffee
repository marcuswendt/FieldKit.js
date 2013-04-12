util = require("util")


###
  JavaScript Language Utilities
  ------------------------------------------------------------------------------------------
###
extend = (obj, source) ->
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


###

  Swappable Mixins in CoffeeScript


  Many thanks to Hashmal, who wrote this to start.
  https://gist.github.com/803816/aceed8fc57188c3a19ce2eccdb25acb64f2be94e

  Usage
  -----

  class Derp extends Mixin
    setup: ->
      @googly = "eyes"

  derp: ->
    alert "Herp derp! What's with your #{ @googly }?"

  class Herp
    constructor: ->
      Derp::augment this

  herp = new Herp
  herp.derp()

  Mixin
  -----

  Classes inheriting `Mixin` will become removable mixins, enabling you to
  swap them around.

  Limitations
  -----------

  * When a class is augmented, all instances of that class are augmented too,
    and when a mixin is ejected from a class, all instances lose that mixin too.
  * You can't eject a mixin from an object if that mixin was added to the object's class. Eject the mixin from the class instead.

###
class Mixin

  # "Class method". Augment object or class `t` with new methods.
  augment: (t) ->
    (t[n] = m unless n == 'augment' or !this[n].prototype?) for n, m of this
    t.setup()

  # When an object is augmented with at least one mixin, call this method to
  # remove `mixin`.
  eject: (mixin) ->
    (delete this[n] if m in (p for o, p of mixin::)) for n, m of this

  # Implement in your mixin to act as a constructor for mixed-in properties
  setup: ->




###

  Clones (copies) an Object using deep copying.


  This function supports circular references by default, but if you are certain
  there are no circular references in your object, you can save some CPU time
  by calling clone(obj, false).

  Caution: if `circular` is false and `parent` contains circular references,
  your program may enter an infinite loop and crash.

  @param `parent` - the object to be cloned
  @param `circular` - set to true if the object to be cloned may contain
  circular references. (optional - true by default)

###
clone = (parent, circular) ->
  circular = true  if typeof circular is "undefined"
  useBuffer = typeof Buffer isnt "undefined"
  i = undefined
  if circular
    _clone = (parent, context, child, cIndex) ->
      i = undefined # Use local context within this function
      # Deep clone all properties of parent into child
      if typeof parent is "object"
        return parent  unless parent?

        # Check for circular references
        for i of circularParent
          if circularParent[i] is parent

            # We found a circular reference
            circularReplace.push
              resolveTo: i
              child: child
              i: cIndex

            return null #Just return null for now...
        # we will resolve circular references later

        # Add to list of all parent objects
        circularParent[context] = parent

        # Now continue cloning...
        if util.isArray(parent)
          child = []
          for i of parent
            child[i] = _clone(parent[i], context + "[" + i + "]", child, i)
        else if util.isDate(parent)
          child = new Date(parent.getTime())
        else if util.isRegExp(parent)
          child = new RegExp(parent.source)
        else if useBuffer and Buffer.isBuffer(parent)
          child = new Buffer(parent.length)
          parent.copy child
        else
          child = {}

          # Also copy prototype over to new cloned object
          child.__proto__ = parent.__proto__
          for i of parent
            child[i] = _clone(parent[i], context + "[" + i + "]", child, i)

        # Add to list of all cloned objects
        circularResolved[context] = child
      else #Just a simple shallow copy will do
        child = parent
      child
    circularParent = {}
    circularResolved = {}
    circularReplace = []
    cloned = _clone(parent, "*")

    # Now this object has been cloned. Let's check to see if there are any
    # circular references for it
    for i of circularReplace
      c = circularReplace[i]
      c.child[c.i] = circularResolved[c.resolveTo]  if c and c.child and c.i of c.child
    cloned
  else

    # Deep clone all properties of parent into child
    child = undefined
    if typeof parent is "object"
      return parent  unless parent?
      if parent.constructor.name is "Array"
        child = []
        for i of parent
          child[i] = clone(parent[i], circular)
      else if util.isDate(parent)
        child = new Date(parent.getTime())
      else unless util.isRegExp(parent)
        child = {}
        child.__proto__ = parent.__proto__
        for i of parent
          child[i] = clone(parent[i], circular)
    else # Just a simple shallow clone will do
      child = parent
    child


clone.clonePrototype = (parent) ->
  return null  if parent is null
  ctor = ->

  ctor:: = parent
  new ctor()


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
class EXObject
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



###
  Array Utilities
  ------------------------------------------------------------------------------------------
###
# removes the element from the given list (if it exists) and returns the list
removeElement = (element, list) ->
  index = list.indexOf element
  list.splice index, 1 unless index is -1
  list


# shuffles the order of the given object or array
# optionally takes a random number generator object
# returns the shuffled object
shuffle = (object, rng) ->
  rng = Math unless rng?
  i = object.length
  while i
    j = parseInt(rng.random() * i)
    x = object[--i]
    object[i] = object[j]
    object[j] = x
  object


module.exports =
  extend: extend
  clone: clone

  EXObject: EXObject
  Mixin: Mixin

  removeElement: removeElement
  shuffle: shuffle
