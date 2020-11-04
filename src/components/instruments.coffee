waveTables = {}
samples = {}
window.instruments =
  Osc1x: (opts) ->
    gain = opts.audio.createGain()
    osc = opts.audio.createOscillator()
    osc.frequency.value = opts.note.freq or notesByMIDINo[opts.note.noteNo]?.freq or notesByName[opts.note.noteName]
    if opts.note.track.instrument.periodicWave
      osc.setPeriodicWave waveTables[opts.note.track.instrument.periodicWave]
    osc.connect gain
    gain.gain.value = opts.note.gain if opts.note.gain
    load: (name) ->
      name = name or opts.name
      return if waveTables[name]
      response = await fetch 'https://ndxbxrme.github.io/yma-full/assets/wave-tables/' + name
      data = JSON.parse((await response.text()).replace(/'/g, '"').replace(/\n/g, '').replace(/,\]/g, ']').replace(/,\}/g, '}'))
      waveTables[name] = audio.createPeriodicWave data.real, data.imag
    connect: (thing) ->
      gain.connect thing
    start: (time) ->
      osc.start time
    stop: (time) ->
      osc.stop time
  Sample: (opts) ->
    gain = opts.audio.createGain()
    source = opts.audio.createBufferSource()
    source.buffer = samples[opts.note.track.instrument.sample]
    source.playbackRate.setValueAtTime(opts.note.playbackRate or opts.note.track.instrument.playbackRate, opts.audio.currentTime) if opts.note.playbackRate or opts.note.track.instrument.playbackRate
    gain.gain.value = opts.note.gain if opts.note.gain
    source.connect gain
    load: (uri) ->
      return if samples[uri]
      response = await fetch uri
      arrayBuffer = await response.arrayBuffer()
      audioBuffer = await audio.decodeAudioData arrayBuffer
      samples[uri] = audioBuffer
    connect: (thing) ->
      gain.connect thing
    start: (time) ->
      source.start time
    stop: (time) ->
      source.stop time
  Waveform: (opts) ->
    gain = opts.audio.createGain()
    source = opts.audio.createBufferSource()
    source.buffer = opts.note.track.instrument.waveform.getBuffer()
    source.playbackRate.setValueAtTime(opts.note.playbackRate or opts.note.track.instrument.playbackRate, opts.audio.currentTime) if opts.note.playbackRate or opts.note.track.instrument.playbackRate
    gain.gain.value = opts.note.gain if opts.note.gain
    source.connect gain
    connect: (thing) ->
      gain.connect thing
    start: (time) ->
      source.start time
    stop: (time) ->
      source.stop time
  WaveformConst: (opts) ->
    if not opts.note.track.source
      opts.note.track.constant = true
      opts.note.track.source = source = opts.audio.createBufferSource()
      source.buffer = opts.note.track.instrument.waveform.getBuffer()
      source.loop = true
      opts.note.track.gain = gain = opts.audio.createGain()
      source.connect gain
      gain.connect opts.note.track.destination
    source.playbackRate.setValueAtTime(opts.note.playbackRate or opts.note.track.instrument.playbackRate, opts.audio.currentTime) if opts.note.playbackRate or opts.note.track.instrument.playbackRate
    constant: true
    start: (time) -> null
    stop: (time) ->
      source.stop time
module.exports = window.instruments