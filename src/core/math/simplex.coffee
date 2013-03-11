# Ported from Stefan Gustavson's java implementation
# http://staffwww.itn.liu.se/~stegu/simplexnoise/simplexnoise.pdf
# Read Stefan's excellent paper for details on how this code works.
#
# Sean McCullough banksean@gmail.com
#
# Added 4D noise
# Joshua Koo zz85nus@gmail.com

###
You can pass in a random number generator object if you like.
It is assumed to have a random() method.
###
class SimplexNoise

  constructor: (@r) ->
    @r = Math  if @r is `undefined`
    @grad3 = [[1, 1, 0], [-1, 1, 0], [1, -1, 0], [-1, -1, 0], [1, 0, 1], [-1, 0, 1], [1, 0, -1], [-1, 0, -1], [0, 1, 1], [0, -1, 1], [0, 1, -1], [0, -1, -1]]
    @grad4 = [[0, 1, 1, 1], [0, 1, 1, -1], [0, 1, -1, 1], [0, 1, -1, -1], [0, -1, 1, 1], [0, -1, 1, -1], [0, -1, -1, 1], [0, -1, -1, -1], [1, 0, 1, 1], [1, 0, 1, -1], [1, 0, -1, 1], [1, 0, -1, -1], [-1, 0, 1, 1], [-1, 0, 1, -1], [-1, 0, -1, 1], [-1, 0, -1, -1], [1, 1, 0, 1], [1, 1, 0, -1], [1, -1, 0, 1], [1, -1, 0, -1], [-1, 1, 0, 1], [-1, 1, 0, -1], [-1, -1, 0, 1], [-1, -1, 0, -1], [1, 1, 1, 0], [1, 1, -1, 0], [1, -1, 1, 0], [1, -1, -1, 0], [-1, 1, 1, 0], [-1, 1, -1, 0], [-1, -1, 1, 0], [-1, -1, -1, 0]]
    @p = []
    i = 0

    while i < 256
      @p[i] = Math.floor(r.random() * 256)
      i++

    # To remove the need for index wrapping, double the permutation table length
    @perm = []
    i = 0

    while i < 512
      @perm[i] = @p[i & 255]
      i++

    # A lookup table to traverse the simplex around a given point in 4D.
    # Details can be found where this table is used, in the 4D noise method.
    @simplex = [[0, 1, 2, 3], [0, 1, 3, 2], [0, 0, 0, 0], [0, 2, 3, 1], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [1, 2, 3, 0], [0, 2, 1, 3], [0, 0, 0, 0], [0, 3, 1, 2], [0, 3, 2, 1], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [1, 3, 2, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [1, 2, 0, 3], [0, 0, 0, 0], [1, 3, 0, 2], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [2, 3, 0, 1], [2, 3, 1, 0], [1, 0, 2, 3], [1, 0, 3, 2], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [2, 0, 3, 1], [0, 0, 0, 0], [2, 1, 3, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [2, 0, 1, 3], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [3, 0, 1, 2], [3, 0, 2, 1], [0, 0, 0, 0], [3, 1, 2, 0], [2, 1, 0, 3], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [3, 1, 0, 2], [0, 0, 0, 0], [3, 2, 0, 1], [3, 2, 1, 0]]

  dot: (g, x, y) ->
    g[0] * x + g[1] * y

  noise: (xin, yin) ->
    n0 = undefined # Noise contributions from the three corners
    n1 = undefined
    n2 = undefined
    # Skew the input space to determine which simplex cell we're in
    F2 = 0.5 * (Math.sqrt(3.0) - 1.0)
    s = (xin + yin) * F2 # Hairy factor for 2D
    i = Math.floor(xin + s)
    j = Math.floor(yin + s)
    G2 = (3.0 - Math.sqrt(3.0)) / 6.0
    t = (i + j) * G2
    X0 = i - t # Unskew the cell origin back to (x,y) space
    Y0 = j - t
    x0 = xin - X0 # The x,y distances from the cell origin
    y0 = yin - Y0

    # For the 2D case, the simplex shape is an equilateral triangle.
    # Determine which simplex we are in.
    i1 = undefined # Offsets for second (middle) corner of simplex in (i,j) coords
    j1 = undefined
    if x0 > y0 # lower triangle, XY order: (0,0)->(1,0)->(1,1)
      i1 = 1
      j1 = 0
    else # upper triangle, YX order: (0,0)->(0,1)->(1,1)
      i1 = 0
      j1 = 1
    # A step of (1,0) in (i,j) means a step of (1-c,-c) in (x,y), and
    # a step of (0,1) in (i,j) means a step of (-c,1-c) in (x,y), where
    # c = (3-sqrt(3))/6
    x1 = x0 - i1 + G2 # Offsets for middle corner in (x,y) unskewed coords
    y1 = y0 - j1 + G2
    x2 = x0 - 1.0 + 2.0 * G2 # Offsets for last corner in (x,y) unskewed coords
    y2 = y0 - 1.0 + 2.0 * G2

    # Work out the hashed gradient indices of the three simplex corners
    ii = i & 255
    jj = j & 255
    gi0 = @perm[ii + @perm[jj]] % 12
    gi1 = @perm[ii + i1 + @perm[jj + j1]] % 12
    gi2 = @perm[ii + 1 + @perm[jj + 1]] % 12

    # Calculate the contribution from the three corners
    t0 = 0.5 - x0 * x0 - y0 * y0
    unless t0 < 0
      t0 *= t0
      n0 = t0 * t0 * @dot(@grad3[gi0], x0, y0) # (x,y) of grad3 used for 2D gradient
    t1 = 0.5 - x1 * x1 - y1 * y1
    unless t1 < 0
      t1 *= t1
      n1 = t1 * t1 * @dot(@grad3[gi1], x1, y1)
    t2 = 0.5 - x2 * x2 - y2 * y2
    unless t2 < 0
      t2 *= t2
      n2 = t2 * t2 * @dot(@grad3[gi2], x2, y2)

    # Add contributions from each corner to get the final noise value.
    # The result is scaled to return values in the interval [-1,1].
    70.0 * (n0 + n1 + n2)


  # 3D simplex noise
  noise3d: (xin, yin, zin) ->
    n0 = undefined # Noise contributions from the four corners
    n1 = undefined
    n2 = undefined
    n3 = undefined
    # Skew the input space to determine which simplex cell we're in
    F3 = 1.0 / 3.0
    s = (xin + yin + zin) * F3 # Very nice and simple skew factor for 3D
    i = Math.floor(xin + s)
    j = Math.floor(yin + s)
    k = Math.floor(zin + s)
    G3 = 1.0 / 6.0 # Very nice and simple unskew factor, too
    t = (i + j + k) * G3
    X0 = i - t # Unskew the cell origin back to (x,y,z) space
    Y0 = j - t
    Z0 = k - t
    x0 = xin - X0 # The x,y,z distances from the cell origin
    y0 = yin - Y0
    z0 = zin - Z0

    # For the 3D case, the simplex shape is a slightly irregular tetrahedron.
    # Determine which simplex we are in.
    i1 = undefined # Offsets for second corner of simplex in (i,j,k) coords
    j1 = undefined
    k1 = undefined
    i2 = undefined # Offsets for third corner of simplex in (i,j,k) coords
    j2 = undefined
    k2 = undefined
    if x0 >= y0
      if y0 >= z0
        i1 = 1 # X Y Z order
        j1 = 0
        k1 = 0
        i2 = 1
        j2 = 1
        k2 = 0
      else if x0 >= z0 # X Z Y order
        i1 = 1
        j1 = 0
        k1 = 0
        i2 = 1
        j2 = 0
        k2 = 1
      else # Z X Y order
        i1 = 0
        j1 = 0
        k1 = 1
        i2 = 1
        j2 = 0
        k2 = 1
    else # x0<y0
      if y0 < z0 # Z Y X order
        i1 = 0
        j1 = 0
        k1 = 1
        i2 = 0
        j2 = 1
        k2 = 1
      else if x0 < z0 # Y Z X order
        i1 = 0
        j1 = 1
        k1 = 0
        i2 = 0
        j2 = 1
        k2 = 1
      else # Y X Z order
        i1 = 0
        j1 = 1
        k1 = 0
        i2 = 1
        j2 = 1
        k2 = 0

    # A step of (1,0,0) in (i,j,k) means a step of (1-c,-c,-c) in (x,y,z),
    # a step of (0,1,0) in (i,j,k) means a step of (-c,1-c,-c) in (x,y,z), and
    # a step of (0,0,1) in (i,j,k) means a step of (-c,-c,1-c) in (x,y,z), where
    # c = 1/6.
    x1 = x0 - i1 + G3 # Offsets for second corner in (x,y,z) coords
    y1 = y0 - j1 + G3
    z1 = z0 - k1 + G3
    x2 = x0 - i2 + 2.0 * G3 # Offsets for third corner in (x,y,z) coords
    y2 = y0 - j2 + 2.0 * G3
    z2 = z0 - k2 + 2.0 * G3
    x3 = x0 - 1.0 + 3.0 * G3 # Offsets for last corner in (x,y,z) coords
    y3 = y0 - 1.0 + 3.0 * G3
    z3 = z0 - 1.0 + 3.0 * G3

    # Work out the hashed gradient indices of the four simplex corners
    ii = i & 255
    jj = j & 255
    kk = k & 255
    gi0 = @perm[ii + @perm[jj + @perm[kk]]] % 12
    gi1 = @perm[ii + i1 + @perm[jj + j1 + @perm[kk + k1]]] % 12
    gi2 = @perm[ii + i2 + @perm[jj + j2 + @perm[kk + k2]]] % 12
    gi3 = @perm[ii + 1 + @perm[jj + 1 + @perm[kk + 1]]] % 12

    # Calculate the contribution from the four corners
    t0 = 0.6 - x0 * x0 - y0 * y0 - z0 * z0
    unless t0 < 0
      t0 *= t0
      n0 = t0 * t0 * @dot(@grad3[gi0], x0, y0, z0)
    t1 = 0.6 - x1 * x1 - y1 * y1 - z1 * z1
    unless t1 < 0
      t1 *= t1
      n1 = t1 * t1 * @dot(@grad3[gi1], x1, y1, z1)
    t2 = 0.6 - x2 * x2 - y2 * y2 - z2 * z2
    unless t2 < 0
      t2 *= t2
      n2 = t2 * t2 * @dot(@grad3[gi2], x2, y2, z2)
    t3 = 0.6 - x3 * x3 - y3 * y3 - z3 * z3
    unless t3 < 0
      t3 *= t3
      n3 = t3 * t3 * @dot(@grad3[gi3], x3, y3, z3)

    # Add contributions from each corner to get the final noise value.
    # The result is scaled to stay just inside [-1,1]
    32.0 * (n0 + n1 + n2 + n3)


  # 4D simplex noise
  noise4d: (x, y, z, w) ->

    # For faster and easier lookups
    grad4 = @grad4
    simplex = @simplex
    perm = @perm

    # The skewing and unskewing factors are hairy again for the 4D case
    F4 = (Math.sqrt(5.0) - 1.0) / 4.0
    G4 = (5.0 - Math.sqrt(5.0)) / 20.0
    n0 = undefined # Noise contributions from the five corners
    n1 = undefined
    n2 = undefined
    n3 = undefined
    n4 = undefined
    # Skew the (x,y,z,w) space to determine which cell of 24 simplices we're in
    s = (x + y + z + w) * F4 # Factor for 4D skewing
    i = Math.floor(x + s)
    j = Math.floor(y + s)
    k = Math.floor(z + s)
    l = Math.floor(w + s)
    t = (i + j + k + l) * G4 # Factor for 4D unskewing
    X0 = i - t # Unskew the cell origin back to (x,y,z,w) space
    Y0 = j - t
    Z0 = k - t
    W0 = l - t
    x0 = x - X0 # The x,y,z,w distances from the cell origin
    y0 = y - Y0
    z0 = z - Z0
    w0 = w - W0

    # For the 4D case, the simplex is a 4D shape I won't even try to describe.
    # To find out which of the 24 possible simplices we're in, we need to
    # determine the magnitude ordering of x0, y0, z0 and w0.
    # The method below is a good way of finding the ordering of x,y,z,w and
    # then find the correct traversal order for the simplex we’re in.
    # First, six pair-wise comparisons are performed between each possible pair
    # of the four coordinates, and the results are used to add up binary bits
    # for an integer index.
    c1 = (if (x0 > y0) then 32 else 0)
    c2 = (if (x0 > z0) then 16 else 0)
    c3 = (if (y0 > z0) then 8 else 0)
    c4 = (if (x0 > w0) then 4 else 0)
    c5 = (if (y0 > w0) then 2 else 0)
    c6 = (if (z0 > w0) then 1 else 0)
    c = c1 + c2 + c3 + c4 + c5 + c6
    i1 = undefined # The integer offsets for the second simplex corner
    j1 = undefined
    k1 = undefined
    l1 = undefined
    i2 = undefined # The integer offsets for the third simplex corner
    j2 = undefined
    k2 = undefined
    l2 = undefined
    i3 = undefined # The integer offsets for the fourth simplex corner
    j3 = undefined
    k3 = undefined
    l3 = undefined
    # simplex[c] is a 4-vector with the numbers 0, 1, 2 and 3 in some order.
    # Many values of c will never occur, since e.g. x>y>z>w makes x<z, y<w and x<w
    # impossible. Only the 24 indices which have non-zero entries make any sense.
    # We use a thresholding to set the coordinates in turn from the largest magnitude.
    # The number 3 in the "simplex" array is at the position of the largest coordinate.
    i1 = (if simplex[c][0] >= 3 then 1 else 0)
    j1 = (if simplex[c][1] >= 3 then 1 else 0)
    k1 = (if simplex[c][2] >= 3 then 1 else 0)
    l1 = (if simplex[c][3] >= 3 then 1 else 0)

    # The number 2 in the "simplex" array is at the second largest coordinate.
    i2 = (if simplex[c][0] >= 2 then 1 else 0)
    j2 = (if simplex[c][1] >= 2 then 1 else 0)
    k2 = (if simplex[c][2] >= 2 then 1 else 0)
    l2 = (if simplex[c][3] >= 2 then 1 else 0)

    # The number 1 in the "simplex" array is at the second smallest coordinate.
    i3 = (if simplex[c][0] >= 1 then 1 else 0)
    j3 = (if simplex[c][1] >= 1 then 1 else 0)
    k3 = (if simplex[c][2] >= 1 then 1 else 0)
    l3 = (if simplex[c][3] >= 1 then 1 else 0)

    # The fifth corner has all coordinate offsets = 1, so no need to look that up.
    x1 = x0 - i1 + G4 # Offsets for second corner in (x,y,z,w) coords
    y1 = y0 - j1 + G4
    z1 = z0 - k1 + G4
    w1 = w0 - l1 + G4
    x2 = x0 - i2 + 2.0 * G4 # Offsets for third corner in (x,y,z,w) coords
    y2 = y0 - j2 + 2.0 * G4
    z2 = z0 - k2 + 2.0 * G4
    w2 = w0 - l2 + 2.0 * G4
    x3 = x0 - i3 + 3.0 * G4 # Offsets for fourth corner in (x,y,z,w) coords
    y3 = y0 - j3 + 3.0 * G4
    z3 = z0 - k3 + 3.0 * G4
    w3 = w0 - l3 + 3.0 * G4
    x4 = x0 - 1.0 + 4.0 * G4 # Offsets for last corner in (x,y,z,w) coords
    y4 = y0 - 1.0 + 4.0 * G4
    z4 = z0 - 1.0 + 4.0 * G4
    w4 = w0 - 1.0 + 4.0 * G4

    # Work out the hashed gradient indices of the five simplex corners
    ii = i & 255
    jj = j & 255
    kk = k & 255
    ll = l & 255
    gi0 = perm[ii + perm[jj + perm[kk + perm[ll]]]] % 32
    gi1 = perm[ii + i1 + perm[jj + j1 + perm[kk + k1 + perm[ll + l1]]]] % 32
    gi2 = perm[ii + i2 + perm[jj + j2 + perm[kk + k2 + perm[ll + l2]]]] % 32
    gi3 = perm[ii + i3 + perm[jj + j3 + perm[kk + k3 + perm[ll + l3]]]] % 32
    gi4 = perm[ii + 1 + perm[jj + 1 + perm[kk + 1 + perm[ll + 1]]]] % 32

    # Calculate the contribution from the five corners
    t0 = 0.6 - x0 * x0 - y0 * y0 - z0 * z0 - w0 * w0
    unless t0 < 0
      t0 *= t0
      n0 = t0 * t0 * @dot(grad4[gi0], x0, y0, z0, w0)
    t1 = 0.6 - x1 * x1 - y1 * y1 - z1 * z1 - w1 * w1
    unless t1 < 0
      t1 *= t1
      n1 = t1 * t1 * @dot(grad4[gi1], x1, y1, z1, w1)
    t2 = 0.6 - x2 * x2 - y2 * y2 - z2 * z2 - w2 * w2
    unless t2 < 0
      t2 *= t2
      n2 = t2 * t2 * @dot(grad4[gi2], x2, y2, z2, w2)
    t3 = 0.6 - x3 * x3 - y3 * y3 - z3 * z3 - w3 * w3
    unless t3 < 0
      t3 *= t3
      n3 = t3 * t3 * @dot(grad4[gi3], x3, y3, z3, w3)
    t4 = 0.6 - x4 * x4 - y4 * y4 - z4 * z4 - w4 * w4
    unless t4 < 0
      t4 *= t4
      n4 = t4 * t4 * @dot(grad4[gi4], x4, y4, z4, w4)

    # Sum up and scale the result to cover the range [-1,1]
    27.0 * (n0 + n1 + n2 + n3 + n4)