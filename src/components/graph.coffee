waveTables = {}
waveforms = {}
Notes = require './notes'
noise = require './noise'
atob = (str) ->
  Buffer.from(str, 'base64').toString()
Waveform = (data) ->
  getRegions: -> data.regions
  getBuffer: ->
    length: data.buffer[0].length
  getValueAtTime: (time) ->
    time = time % 1
    output = []
    c = 0
    while c < data.buffer.length
      channelData = data.buffer[c]
      channelTime = channelData.length * time
      channelIndex = Math.floor channelTime
      channelFrac = channelTime - Math.trunc channelTime
      data0 = channelData[channelIndex]
      if channelIndex < channelData.length
        data1 = channelData[channelIndex + 1]
      else
        data1 = data0
      val = data0 + (data1 - data0) * channelFrac
      output.push val
      c++
    output
  getRmsAtTime: (time) ->
    time = time % 1
    output = []
    c = 0
    while c < data.rmsData.length
      channelData = data.rmsData[c]
      channelTime = channelData.length * time
      channelIndex = Math.floor channelTime
      channelFrac = channelTime - Math.trunc channelTime
      data0 = channelData[channelIndex]
      if channelIndex < channelData.length
        data1 = channelData[channelIndex + 1]
      else
        data1 = data0
      val = data0 + (data1 - data0) * channelFrac
      output.push val
      c++
    output
ProjectManager =
  getWaveforms: -> waveforms
Graph = (text='return x', multiplier=1, offset=0, range={"h":[0,1],"v":[-0.1,1.1]}, tempo=60, beats=1) ->
  noise.reset()
  canvas = null
  time = 0
  audio = null
  filterData = {}
  notes = {}
  loadAudioFile = (file) ->
    audio = audio or new AudioContext()
    return if waveforms[file.name]
    waveforms[file.name] = await Waveform(audio).fromFile file
  loadWaveTable = (name) ->
    audio = audio or new AudioContext()
    return if waveTables[name]
    response = await fetch 'https://ndxbxrme.github.io/yma-full/assets/wave-tables/' + name
    data = JSON.parse((await response.text()).replace(/'/g, '"').replace(/\n/g, '').replace(/,\]/g, ']').replace(/,\}/g, '}'))
    waveTables[name] = audio.createPeriodicWave data.real, data.imag
    waveform = Waveform audio
    await waveform.renderOscillator (ctx) ->
      osc = ctx.createOscillator()
      osc.frequency.value = 1
      osc.setPeriodicWave waveTables[name]
      osc
    , audio.sampleRate
    waveforms[name] = waveform
  analyzeWaveform = (name) ->
    return if ProjectManager.getWaveforms()[name].getRmsData()?.length
    await ProjectManager.getWaveforms()[name].analyze()
  hash = (str) ->
    h = 5381
    i = str.length
    while i
      h = (h * 33) ^ str.charCodeAt --i
    h
  util =
    f: (freq, nobeats) ->
      freq * (60 / tempo) * (nobeats or beats)
    wt: (name, x) ->
      waveforms[name].getValueAtTime x
    wf: (name, x) ->
      ProjectManager.getWaveforms()[name].getValueAtTime x
    graph: (name, x) ->
      ProjectManager.getGraphs()[name].getValue x
    rms: (name, x) ->
      ProjectManager.getWaveforms()[name].getRmsAtTime x
    makeNotes: (name, mynotes, offset) ->
      notes[name] = notes[name] or Notes.byMIDINo.filter((note, i) -> mynotes.map((item)->(item + offset) % 12).includes(i % 12))
    note: (name, num) ->
      notes[name][num]
    bc: (x, num, len) ->
      len = len or 8
      (((1 << Math.floor(len - x * len)) & num) > 0 ? 1 : 0)
    ws: (x) -> 1.5 * x - 0.5 * Math.pow(x,3)
    clamp: (x, min, max) -> Math.min(max, Math.max(min, x))
    ramp: (x) -> 
      x = x % 1
      x
    scurve: (x, factor) ->
      x = x * 2 / 1 - 1;
      k = factor or 10;
      .5 + (3 + k) * x * 28.7 * (Math.PI / 180) / (Math.PI + k * Math.abs(x))
    seq: (x, beats, steps, fn) ->
      nosteps = beats * steps
      steplength = 1 / steps
      x *= beats
      cell = Math.floor x * steps
      x %= steplength
      stepx = x * steps
      start = cell
      count = 0
      ison = fn cell
      while (not ison) and (count < nosteps)
        start--
        start = nosteps - 1 if start < 0
        ison = fn start
        count++
      x = x + count * steplength
      [
        Math.min(1, Math.max(0, if x > 1 then 0 else x))
        if cell - count < 0 then cell - count + nosteps else cell - count
        if fn cell + 1 then @clamp((1 - stepx) * 100, 0, 1) else 1
      ]
    adr: (x, a, d, r) ->
      @clamp(Math.pow(1 - (x - d), r), 0, 1) * Math.sin((@clamp(x, 0, a)) * Math.PI * 2 * 1 / a * .25)
    adsr: (x, at, dt, dv, st, sv, rt) ->
      curve = (x, from, to) -> (.5 + .5 * Math.sin((x * .5 + .25) * Math.PI * 2)) * (to - from) + from
      (x < at and curve(x * 1 / at, 1, 0)) or (x >= at and x < at + dt and curve((x - at) * 1 / dt, dv, 1)) or (x >= at + dt and x < at + dt + st and curve((x - (at + dt)) * 1 / st, sv, dv)) or (x >= at + dt + st and x <= at + dt + st + rt and curve((x - (at + dt + st)) * 1 / rt, 0, sv))
    gs: (name, x, multiplier, offset) ->
      x %= 1
      x1 = x + .5
      x1 %= 1
      allx = x
      jig = (@clamp((x - .4) * 10, 0, 1) * @clamp((1 - x) * 10, 0, 1))
      x *= multiplier
      x1 *= multiplier
      x += offset
      x1 += offset
      out = @wf(name, x1)[0] * (1 - jig)
      out += @wf(name, x)[0] * (jig)
      out
    region: (name, x, regionNo) ->
      x %= 1
      wf = ProjectManager.getWaveforms()[name]
      regions = wf.getRegions()
      length = wf.getBuffer().length
      regionNo = regionNo % regions.length
      region = regions[regionNo]
      rstart =  region.start / length
      #console.log 'rst', rstart, length
      rend = region.end / length
      rlen = rend - rstart
      #console.log rstart, rend, rlen
      #console.log 'r', x, @clamp((rlen - x) * 100, 0, 1)
      val = wf.getValueAtTime(x + rstart)
      val.map (item) => item# * @clamp((rlen - x) * 100, 0, 1)
  innerfn = new Function "x,noise,util,seed,time,notesByMIDINo,notesByName", text
  fn = (_multiplier=multiplier, _offset=offset) -> (x, noise, util, seed, time, notesByMIDINo, notesByName) -> innerfn(x, noise, util, seed, time, notesByMIDINo, notesByName) * +_multiplier + +_offset  
  ###
  wavetablesToLoad = (text.match(/wt\(\s*['"].*?['"]/g) or []).map((item) -> item.replace(/wt\(\s*|['"]/g, ''))
  if wavetablesToLoad.length
    for wavetableName in wavetablesToLoad
      await loadWaveTable wavetableName
  waveformsToAnalyze = (text.match(/(rms|region)\([\sx,]*['"].*?['"]/g) or []).map((item) -> item.replace(/(rms|region)\([\sx,]*|['"]/g, ''))
  console.log 'waveformsToAnalyze', waveformsToAnalyze
  if waveformsToAnalyze.length
    for waveformName in waveformsToAnalyze
      await analyzeWaveform waveformName
  ###
  fn: fn
  setCanvas: (_canvas) -> canvas = _canvas
  setTime: (_time) -> time = _time
  getText: -> text
  getMultiplier: -> multiplier
  getOffset: -> offset
  getRange: -> range
  getTempo: -> tempo
  getBeats: -> beats
  getValue: (x) ->
    fn() x, noise, util, 200, time, Notes.byMIDINo, Notes.byName
  toBase64: ->
    btoa JSON.stringify
      text: text
      multiplier: multiplier
      offset: offset
      range: range
      tempo: tempo
      beats: beats
  draw: ->
    canvas.width = canvas.offsetWidth
    ctx = canvas.getContext '2d'
    ctx.clearRect 0, 0, canvas.width, canvas.height
    myx = 0
    ctx.beginPath()
    ctx.strokeStyle = '#000000'
    ctx.lineWidth = 2
    minY = Number.MAX_SAFE_INTEGER
    maxY = Number.MIN_SAFE_INTEGER
    while myx <= canvas.width
      x = myx / canvas.width * (range.h[1] - range.h[0]) + range.h[0]
      y = fn() x, noise, util, 200, time, Notes.byMIDINo, Notes.byName
      minY = Math.min minY, y
      maxY = Math.max maxY, y
      myy = canvas.height - (y - range.v[0]) / (range.v[1] - range.v[0]) * canvas.height
      ctx[if myx is 0 then 'moveTo' else 'lineTo'] myx, myy
      myx++
    ctx.lineTo canvas.width + 10, canvas.height + 10
    ctx.lineTo -10, canvas.height + 10
    ctx.lineTo 0, fn(x, window.noise, 200)
    grd = ctx.createLinearGradient 0, 0, 0, 200
    grd.addColorStop 0, 'lightblue'
    grd.addColorStop 1, 'white'
    ctx.fillStyle = grd
    ctx.fill()
    ctx.stroke()
    $('.minmax')?.innerText = 'min:' + minY.toFixed(3) + ', max:' + maxY.toFixed(3)
  loadAudioFile: loadAudioFile
  setWaveforms: (wfs) ->
    for wfName, wf of wfs
      waveforms[wfName] = Waveform wf
Graph.fromBase64 = (b64) ->
  data = JSON.parse atob b64
  await Graph data.text, data.multiplier, data.offset, data.range, (data.tempo or 60), (data.beats or 1)
Graph.fromGraph = (graph, multiplier, offset, tempo, beats) ->
  #data = graph.toBase64()
  await Graph graph.getText(), multiplier or graph.getMultiplier(), offset or graph.getOffset(), graph.getRange(), tempo or (graph.getTempo() or 60), beats or (graph.getBeats() or 1)
Graph.getWaveforms = ->
  waveforms
  
#window.Graph = Graph
module.exports = Graph