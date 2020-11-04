{blue, green, pink, red, violet, white} = require '@thi.ng/colored-noise'
its = {}
getNoise = (fn, args) ->
  name = fn.toString() + JSON.stringify(args)
  if not its[name]
    its[name] = fn.apply(@, Array.from(args).slice(args.length - 2))
  its[name].next()
noise =
  reset: ->
    its = {}
  frac: (x) ->
    x - Math.trunc(x)
  hash: (x) ->
    v = Math.sin(x * 1523.234235236) * 2342352.23423523
    Math.abs @frac(v)
  pn: (x) ->
    n1 = @hash Math.trunc(x)
    n2 = @hash Math.trunc(x) + 1
    n1 + @frac(x) * (n2 - n1)
  cn: (x) ->
    k = Math.trunc x
    tf = 1
    tang = (k) => tf  * (@hash(k + 1) - @hash(k - 1)) / 2
    m = [tang(k), tang(k + 1)]
    p = [@hash(k), @hash(k + 1)]
    t = x - k
    t2 = t * t
    t3 = t * t2
    (2 * t3 - 3 * t2 + 1) * p[0] + (t3 - 2 * t2 + t) * m[0] + (-2 * t3 + 3 * t2) * p[1] + (t3 - t2) * m[1]
  blue: -> getNoise blue, arguments
  green: -> getNoise green, arguments
  pink: -> getNoise pink, arguments
  red: -> getNoise red, arguments
  violet: -> getNoise violet, arguments
  white: -> getNoise white, arguments

module.exports = noise