window.ADSR = (opts) ->
  id = ogid()
  if opts.note?.track.gain
    gain = opts.note?.track.gain
  else
    gain = opts.audio.createGain()
    gain.gain.value = 0
  a = opts.time + opts.attackTime
  d = a + opts.decayTime
  s = d + opts.sustainTime
  r = s + opts.releaseTime
  av = opts.attackValue
  dv = opts.decayValue
  sv = opts.sustainValue
  gain.gain.setValueAtTime 0, opts.time
  gain.gain.linearRampToValueAtTime av, Math.max a, 0
  gain.gain.linearRampToValueAtTime dv, Math.max d, 0
  if not opts.hold
    gain.gain.linearRampToValueAtTime sv, Math.max s, 0
    gain.gain.linearRampToValueAtTime 0, Math.max r, 0
  if opts.osc
    opts.osc.start opts.time
    if not opts.hold
      opts.osc.stop r
      setTimeout ->
        opts.onStop? id
      , (r - opts.audio.currentTime) * 1000
  connect: gain.connect
  gain: gain
  stop: ->
    gain.gain.cancelScheduledValues opts.audio.currentTime
    gain.gain.linearRampToValueAtTime 0, opts.releaseTime
    if opts.time >= opts.audio.currentTime + opts.releaseTime
      opts.osc.stop opts.time + 10
    else
      opts.osc.stop(opts.audio.currentTime + opts.releaseTime) if opts.osc
    setTimeout ->
      opts.onStop? id
    , opts.releaseTime * 1000
module.exports = window.ADSR