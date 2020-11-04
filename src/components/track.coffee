window.Track = (opts) ->
  gain = opts.audio.createGain()
  id: ogid()
  pointer: 0
  wrap: true
  steps: opts.steps or 4
  lastTime: -1
  tempo: opts.tempo
  current: {}
  notes: []
  addNote: (note) ->
    pointerNote = @notes[@pointer]
    if pointerNote and pointerNote.time > note.time
      @pointer++
    note.track = @
    note.id = ogid()
    @notes.push note
    @notes.sort (a, b) ->
      if a.time < b.time then -1 else 1
    note
  removeNote: (note) ->
    pointerNote = @notes[@pointer]
    if pointerNote and pointerNote.time < note.time
      @pointer--
    @notes.splice @notes.indexOf(note), 1
  destination: gain
  connect: (thing) ->
    gain.connect thing
module.exports = window.Track