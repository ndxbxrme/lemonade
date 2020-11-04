DrumMachine = (audio, seq) ->
  tracks = []
  stabilityHits =
    kick:
      regular: [
        [1,0,1,0]
        [1,0,0,0]
        [1,0,0,0,0,0,0,0]
        [0,0,0,0]
      ]
      halftime: [
        [1,0,0,0]
        [1,0,0,0]
        [1,0,0,0,0,0,0,0]
        [0,0,0,0]
      ]
    snare:
      regular: [
        [0,1,0,1]
        [0,1,0,0]
        [0,0,0,0]
      ]
      halftime: [
        [0,0,1,0]
        [0,0,1,0]
        [0,0,0,0]
      ]
  makeBar = (seed, track, steps, start) ->
    i = 0
    while i < steps
      if noise.hash(seed++) < track.graphs.trigger?.getValue(i / steps) * track.graphs.busyness?.getValue((start + i) / track.steps)
        if track.exclude
          console.log 'got exclude'
          #get all tracks from exclude group
          foundNote = false
          excludeGroup = tracks.filter (item) -> item.exclude is track.exclude
          if excludeGroup.length
            for exclude in excludeGroup
              [foundNote] = exclude.notes.filter (item) -> item.time is start + i
              console.log 'found note', foundNote
              break if foundNote
          #continue if foundNote
        if not foundNote
          console.log track.dmType, start + i
          track.addNote
            time: start + i
            length: 1
            gain: (track.graphs.gain?.getValue(i / steps) or 1) * track.graphs.dynamics?.getValue((start + i) / track.steps)
      i += 1 / 2 / 2
    seed
  addTrack: (opts) ->
    track = seq.addTrack()
    track.instrument =
      type: 'Waveform'
      waveform: opts.waveform
    track.steps = 0
    track.dmType = opts.type
    track.destination = opts.destination if opts.destination
    track.graphs = opts.graphs
    track.exclude = opts.exclude if opts.exclude
    tracks.push track
  getTracks: -> tracks
  setSteps: (steps) ->
    for track in tracks
      track.steps = steps
  addBar: (seeds, start, barNo, steps) ->
    seed = seeds[barNo % seeds.length]
    for track in tracks
      #get stability hits
      hits = stabilityHits[track.dmType]?[if track.graphs.halftime?.getValue(start / track.steps) < .5 then 'regular' else 'halftime']
      if hits
        hits = hits[Math.floor(track.graphs.stability?.getValue(start / track.steps) * hits?.length)]
        continue if not hits
        if hits.length > 4
          mybar = barNo % 2
          hits = hits.slice mybar * 4, 4
        for hit, i in hits
          if hit
            track.addNote
              time: start + i
              length: .5
              gain: (track.graphs.gain?.getValue(i / steps) or 1) * track.graphs.dynamics?.getValue((start + i) / track.steps)  
    for track in tracks    
      seed = makeBar seed, track, steps, start
  getSeq: ->
    seq
window.DrumMachine = DrumMachine
module.exports = DrumMachine