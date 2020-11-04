window.Sequencer = (audio) ->
  mainGain = audio.createGain()
  tempo = 120
  steps = 4
  lookahead = 0.1
  lastTime = -1
  startTime = 0
  playing = true
  tracks = []

  loadSample = (uri) ->
    return if samples[uri]
    response = await fetch uri
    arrayBuffer = await response.arrayBuffer()
    audioBuffer = await audio.decodeAudioData arrayBuffer
    samples[uri] = audioBuffer
  loadWaveTable = (name) ->
    return if waveTables[name]
    response = await fetch 'https://ndxbxrme.github.io/yma-full/assets/wave-tables/' + name
    data = JSON.parse((await response.text()).replace(/'/g, '"').replace(/\n/g, '').replace(/,\]/g, ']').replace(/,\}/g, '}'))
    waveTables[name] = audio.createPeriodicWave data.real, data.imag
  playNote = (time, note) ->
    source = null
    if note.track.instrument.solo
      for id, adsr of note.track.current
        adsr.stop()
    attackTime = note.attackTime or note.track.attackTime or 0.001
    attackValue = note.attackValue or note.track.attackValue or 0.8
    decayTime = note.decayTime or note.track.decayTime or 0.1
    decayValue = note.decayValue or note.track.decayValue or attackValue or 0.1
    sustainTime = note.sustainTime or note.track.sustainTime or 0.5
    sustainValue = note.sustainValue or note.track.sustainValue or decayValue
    releaseTime = note.releaseTime or note.track.releaseTime or 0.01
    if note.length
      length = 60 / (note.track.tempo or seq.getTempo()) * note.length
      sustainTime = length - attackTime - decayTime
    source = instruments[note.track.instrument.type]
      audio: audio
      note: note
    adsr = ADSR
      audio: audio
      time: time
      osc: source
      note: note
      hold: note.track.hold
      attackTime: attackTime
      attackValue: attackValue
      decayTime: decayTime
      decayValue: decayValue
      sustainTime: sustainTime
      sustainValue: sustainValue
      releaseTime: releaseTime
      onStop: (id) ->
        note.playing = false
        delete note.track.current[id]
    if not source.constant
      source.connect adsr.gain
      adsr.gain.connect note.track.destination
    note.playing = true
    note.track.current[adsr.id] = adsr
  nextNote = (track, time) ->
    if note = track.notes[track.pointer]
      if note.time < time
        track.pointer++
        return note
    null
  schedule = ->
    if playing
      for track in tracks
        deg = (track.tempo or tempo) / 60
        currentTime = audio.currentTime - startTime
        timeNow = (currentTime * deg) % (track.steps or steps)
        time = ((currentTime + lookahead) * deg) % (track.steps or steps)
        track.pointer = 0 if time < track.lastTime and track.wrap
        while note = nextNote track, time, track.lastTime
          diff = note.time - time
          playNote audio.currentTime + lookahead + diff / deg, note
        track.lastTime = time
      window.requestAnimationFrame schedule
  setTempo: (newTempo) ->
    tempo = newTempo
    for track in tracks
      track.tempo = newTempo
  setSteps: (newSteps) ->
    steps = newSteps
    for track in tracks
      track.steps = newSteps
  setWrap: (newWrap) ->
    for track in tracks
      track.wrap = newWrap
  setPlayFn: (fn) ->
    playNote = fn
  getTracks: ->
    tracks
  getTempo: ->
    tempo
  addTrack: (wet, dry) ->
    newTrack = Track
      tempo: tempo
      steps: steps
      audio: audio
    tracks.push newTrack
    newTrack.connect mainGain if not wet or dry
    newTrack.connect wet if wet
    newTrack.connect dry if dry
    newTrack
  start: (restart) ->
    document?.body.className = document.body.className.replace(/ *seq-playing/g, '') + ' seq-playing'
    if restart
      startTime = audio.currentTime
      for track in tracks
        track.pointer = 0
        track.lastTime = -1
    playing = true
    schedule()
  stop: ->
    document?.body.className = document.body.className.replace(/ *seq-playing/g, '')
    playing = false
    stopAll = ->
      for track in tracks
        for adsr in track.current
          adsr.stop()
    stopAll()
    setTimeout stopAll, 50 #panic
  load: ->
    for track in tracks
      await track.instrument?.load?()
  connect: (thing) ->
    mainGain.connect thing
module.exports = window.Sequencer