simplex = require './simplex'


# Seeded Perlin Noise
#
# Based on the original by Ken Perlin:
#
# http://mrl.nyu.edu/~perlin/noise/
# http://mrl.nyu.edu/~perlin/paper445.pdf
#
# Seeding function based on code from:
# http://techcraft.codeplex.com/discussions/264014
#
# translated By Lee Grey 2012 - www.lgrey.com
class PerlinNoise
  p: null

  permutation: [151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99,
                37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32,
                57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27,
                166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244,
                102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196, 135, 130,
                116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147,
                118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183, 170, 213, 119,
                248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79,
                113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162,
                241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204, 176, 115,
                121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66,
                215, 61, 156, 180]

  constructor: (seed) ->
    @p = new Array(512)

    #permutation from original by Ken Perlin:
    @permutation
    if seed
      @setSeed seed
    else
      i = 0

      while i < 256
        @p[256 + i] = @p[i] = @permutation[i]
        i++

  setSeed: (seed) ->
    seed = seed or 1337
    @permutation = [] #make permutation unique between instances
    if SeededRandomNumberGenerator is `undefined`
      console.log "PerlinNoiseGenerator.setSeed() - warning," + " SeededRandomNumberGenerator is undefined"
      return
    seedRND = new SeededRandomNumberGenerator()
    seedRND.seed = seed
    i = undefined
    i = 0
    while i < 256
      @permutation[i] = i
      i++
    i = 0
    while i < 256
      k = seedRND.randomIntRange(0, 256 - i) + i #(256 - i) + i;
      l = @permutation[i]
      @permutation[i] = @permutation[k]
      @permutation[k] = l
      @permutation[i + 256] = @permutation[i]
      i++
    i = 0

    while i < 256
      @p[256 + i] = @p[i] = @permutation[i]
      i++

  noise: (x, y, z) ->

    # NOTE: "~~" is a faster approximation of Math.floor()
    # Modern browsers inline Math.floor(), so it may actually be faster...

    #Find unit cube that contains point
    X = ~~(x) & 255
    Y = ~~(y) & 255
    Z = ~~(z) & 255

    #Find relative x,y,z of point in cube
    x -= ~~(x)
    y -= ~~(y)
    z -= ~~(z)

    #compute fade curves for each of x,y,z
    u = @fade(x)
    v = @fade(y)
    w = @fade(z)

    #hash coordinates of the 8 cube corners
    A = @p[X] + Y
    AA = @p[A] + Z
    AB = @p[A + 1] + Z
    B = @p[X + 1] + Y
    BA = @p[B] + Z
    BB = @p[B + 1] + Z

    #and add blended results from 8 corners of cube
    (@lerp(w, @lerp(v, @lerp(u, @grad(@p[AA], x, y, z), @grad(@p[BA], x - 1, y, z)), @lerp(u, @grad(@p[AB], x, y - 1, z), @grad(@p[BB], x - 1, y - 1, z))), @lerp(v, @lerp(u, @grad(@p[AA + 1], x, y, z - 1), @grad(@p[BA + 1], x - 1, y, z - 1)), @lerp(u, @grad(@p[AB + 1], x, y - 1, z - 1), @grad(@p[BB + 1], x - 1, y - 1, z - 1))))) * 0.5 + 0.5 # return value from 0.0 to 1.0, rather than -1.0 to 1.0

  fade: (t) -> t * t * t * (t * (t * 6 - 15) + 10)

  lerp: (t, a, b) -> a + t * (b - a)

  grad: (hash, x, y, z) ->
    #convert LO 4 bits of hash code into 12 gradient directions
    h = hash & 15
    u = (if h < 8 then x else y)
    v = (if h < 4 then y else (if h is 12 or h is 14 then x else z))
    ((if (h & 1) is 0 then u else -u)) + ((if (h & 2) is 0 then v else -v))


###

  Multi Noise Genrator Class

###
class Noise
  generator = null

  constructor: (random) ->
    random = Math unless random?
    generator = new simplex.SimplexNoise(random)

  noise2: (x, y) -> generator.noise2 x, y
  noise3: (x, y, z) -> generator.noise3 x, y, z
  noise4: (x, y, z, w) -> generator.noise4 x, y, z, w

module.exports.Noise = Noise