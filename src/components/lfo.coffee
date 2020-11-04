window.LFO = (opts) ->
  osc = opts.audio.createOscillator()
  osc.frequency.value = opts.frequency or 1
  oscGain = opts.audio.createGain()
  oscGain.gain.value = opts.value or 10
  osc.connect oscGain
  connect: (thing) ->
    oscGain.connect thing
  osc: osc
  gain: oscGain
  start: ->
    osc.start()
  stop: ->
    osc.stop()
module.exports = window.LFO