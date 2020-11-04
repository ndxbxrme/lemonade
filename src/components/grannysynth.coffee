GrannySynth = (audio) ->
  arrs = null
  ws = (x) -> 1.5 * x - 0.5 * Math.pow(x,3)
  dowindow = (x) ->
    x = x % 1
    ws ws ws ws ws(1 - (.5 + .5 * Math.cos(x * 2 * Math.PI)))
  setSource: (waveform) ->
    arrs = waveform.extractRegion 0, waveform.getBuffer().length
  generateWaveform: (seed, length, grainLength) ->
    outarrs = []
    i = 0
    out = new Float32Array length
    while i < length
      g = Math.floor(i / (grainLength * 2))
      r = (i % grainLength)
      x = r / grainLength
      grainStart = Math.floor(noise.pn(g + seed) * (arrs[0].length - grainLength * 1.5))
      out[i] = arrs[0][grainStart + r] * dowindow(x)
      j = i + Math.floor(grainLength / 2)
      g = Math.floor(j / (grainLength * 2))
      r = (j % grainLength)
      x = r / grainLength
      grainStart = Math.floor(noise.pn(g + seed) * (arrs[0].length - grainLength * 1.5))
      out[i] += arrs[0][grainStart + r] * dowindow(x) * .6
      i++
    outarrs.push out
    await Waveform(audio).fromArray outarrs
window.GrannySynth = GrannySynth
module.exports = GrannySynth