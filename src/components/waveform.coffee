Waveform = (audio) ->
  buffer = null
  canvas = null
  channels = []
  regions = []
  frequencyData = []
  rmsData = []
  pitchData = null
  source = null
  fileName = ''
  view =
    start: 0
    stop: 1
  normalize: (threshold) ->
    largestVal = 0
    data = new Float32Array buffer.length
    c = 0
    while c < buffer.numberOfChannels
      buffer.copyFromChannel data, c
      i = 0
      while i < buffer.length
        largestVal = Math.max largestVal, Math.abs data[i]
        i++
      c++
    factor = (threshold or 0.8) / largestVal
    c = 0
    while c < buffer.numberOfChannels
      buffer.copyFromChannel data, c
      i = 0
      while i < buffer.length
        data[i] = data[i] * factor
        i++
      buffer.copyToChannel data, c
      c++
  rectify: ->
    data = new Float32Array buffer.length
    c = 0
    swing = 8
    while c < buffer.numberOfChannels
      buffer.copyFromChannel data, c
      i = 0
      offset = 0
      while i < buffer.length
        min = 1
        max = -1
        b = i
        while b < i + 100 and b < buffer.length
          smp = data[b]
          min = Math.min smp, min
          max = Math.max smp, max
          b++
        nextOffset = min + (max - min) * .5
        diff = nextOffset - offset
        diff /= swing
        offset = offset + diff
        data[i] += offset
        i++
      buffer.copyToChannel data, c
      c++
  trim: ->
    trimStart = buffer.length
    trimEnd = 0
    data = []
    c = 0
    while c < buffer.numberOfChannels
      data[c] = new Float32Array buffer.length
      buffer.copyFromChannel data[c], c
      i = 0
      start = 0
      end = 0
      while i < data[c].length
        if data[c][i] && data[c][i] > 0.01
          start = i if not start
          end = i
        i++
      trimStart = Math.min trimStart, start
      trimEnd = Math.max trimEnd, end
      c++
    buffer = audio.createBuffer data.length, trimEnd - trimStart, audio.sampleRate
    c = 0
    while c < buffer.numberOfChannels
      buffer.copyToChannel data[c].slice(trimStart, trimEnd), c
      c++
  topDeck: ->
    c = 0
    data = new Float32Array buffer.length
    while c < buffer.numberOfChannels
      buffer.copyFromChannel data, c
      i = 0
      bits =
        tops: []
        bottoms: []
        nothing: []
      current = []
      now = 'nothing'
      while i < buffer.length
        if data[i] >= 0
          if now isnt 'tops'
            bits[now].push current
            current = []
            now = 'tops'
        if data[i] < 0
          if now isnt 'bottoms'
            bits[now].push current
            current = []
            now = 'bottoms'
        current.push data[i]
        i++
      bits[now].push current
      bits.bottoms = bits.bottoms.reverse()
      i = 0
      b = 0
      while b < bits.tops.length
        if bits.tops[b]
          for bit in bits.tops[b]
            data[i++] = bit
        if bits.bottoms[b]
          for bit in bits.bottoms[b]
            data[i++] = bit
        b++
      buffer.copyToChannel data, c
      c++
  onlyTops: ->
    c = 0
    data = new Float32Array buffer.length
    while c < buffer.numberOfChannels
      buffer.copyFromChannel data, c
      i = 0
      bits =
        tops: []
        bottoms: []
        nothing: []
      current = []
      now = 'nothing'
      while i < buffer.length
        if data[i] >= 0
          if now isnt 'tops'
            bits[now].push current
            current = []
            now = 'tops'
        if data[i] < 0
          if now isnt 'bottoms'
            bits[now].push current
            current = []
            now = 'bottoms'
        current.push data[i]
        i++
      bits[now].push current
      bits.bottoms = bits.bottoms.reverse()
      i = 0
      b = 0
      while b < bits.tops.length
        if bits.tops[b]
          for bit in bits.tops[b]
            data[i++] = bit
        if bits.bottoms[b]
          for bit in bits.tops[b].reverse()
            data[i++] = -bit
        b++
      buffer.copyToChannel data, c
      c++
    
  analyze: (minLength, threshold, release, ratio) ->
    new Promise (resolve) ->
      stride = 256
      frequencyData = []
      rmsData = new Array(buffer.numberOfChannels).fill []
      rms = require('./rms.coffee') 0.2, 'friction', 0.5, 'friction', 1
      offline = new OfflineAudioContext buffer.numberOfChannels, buffer.length, buffer.sampleRate
      #analyzer = offline.createAnalyser()
      processor = offline.createScriptProcessor stride, buffer.numberOfChannels, buffer.numberOfChannels
      compressor = offline.createDynamicsCompressor()
      source = offline.createBufferSource()
      #source.connect analyzer
      source.connect compressor
      compressor.connect processor
      #analyzer.fftSize = 256
      #analyzer.minDecibels = -90
      #analyzer.maxDecibels = -10
      #aBufLength = analyzer.frequencyBinCount
      compressor.threshold.value = (threshold or -50)
      compressor.release.value = (release or 1)
      compressor.ratio.value = (ratio or 20)
      processor.connect offline.destination
      lastReduction = 0
      lastPosition = 0
      lastDir = 'nothing'
      position = 0
      data = new Array buffer.numberOfChannels
      processor.onaudioprocess = (e) ->
        c = 0
        while c < buffer.numberOfChannels
          data[c] = e.inputBuffer.getChannelData c
          rmsData[c].push rms.process data[c]
          c++
        #dataArray = new Uint8Array aBufLength
        #analyzer.getByteFrequencyData dataArray
        #frequencyData.push dataArray
        if compressor.reduction <= lastReduction
          dir = 'down'
        else
          dir = 'up'
        if dir is 'up' and lastDir isnt 'up'
          if position - lastPosition > (minLength or 4000)
            regions.push position
          lastPosition = position
        lastDir = dir
        lastReduction = compressor.reduction
        position += stride
      offline.oncomplete = ->
        regions.push buffer.length
        lastRegion = -1
        regions = regions.map (item) ->
          start = lastRegion + 1
          lastRegion = item
          start: start
          end: lastRegion
        resolve null
      source.buffer = buffer
      source.start 0
      offline.startRendering()
  pitchDetect: ->
    Pitchfinder = require 'pitchfinder'
    detectors = 
      YIN: Pitchfinder.YIN()
      AMDF: Pitchfinder.AMDF()
      DynamicWavelet: Pitchfinder.DynamicWavelet()
    #detectPitch.sampleRate = audio.sampleRate
    pitchData = Pitchfinder.default.frequencies [detectors.YIN, detectors.AMDF, detectors.DynamicWavelet], buffer.getChannelData(0),
      sampleRate: audio.sampleRate
  renderOscillator: (myosc, length) ->
    new Promise (resolve) ->
      numberOfChannels = 1
      stride = 256
      offline = new OfflineAudioContext numberOfChannels, length + 1, audio.sampleRate
      processor = offline.createScriptProcessor stride, numberOfChannels, numberOfChannels
      osc = myosc offline
      osc.connect processor
      processor.connect offline.destination
      channels = []
      data = []
      c = 0
      while c++ < numberOfChannels
        channels.push new Float32Array length
        data.push new Float32Array stride
      position = 0
      processor.onaudioprocess = (e) ->
        c = 0
        while c < numberOfChannels
          data[c] = e.inputBuffer.getChannelData c
          c++
        i = 0
        while i < data[0].length
          c = 0
          while c < numberOfChannels
            channels[c][position] = data[c][i]
            c++
          position++
          i++
      offline.oncomplete = ->
        buffer = audio.createBuffer numberOfChannels, channels[0].length, audio.sampleRate
        for channel, i in channels
          buffer.copyToChannel channel, i
        resolve null
      osc.start 0
      offline.startRendering()
  renderEffect: (effect, length, offset, wraptail) ->
    length = length or buffer.length
    start = 0
    stop = length
    if offset
      start = Math.floor offset * length
      stop = start + length
    new Promise (resolve) ->
      stride = 1024
      offline = new OfflineAudioContext buffer.numberOfChannels, stop + stride, buffer.sampleRate
      processor = offline.createScriptProcessor stride, buffer.numberOfChannels, buffer.numberOfChannels
      source = offline.createBufferSource()
      if start > 0
        source.loop = true
      effectChain = effect offline
      source.connect effectChain
      effectChain.connect processor
      processor.connect offline.destination
      channels = []
      data = []
      c = 0
      while c++ < buffer.numberOfChannels
        channels.push new Float32Array(length)
        data.push new Float32Array(stride)
      position = 0
      processor.onaudioprocess = (e) ->
        c = 0
        while c < buffer.numberOfChannels
          data[c] = e.inputBuffer.getChannelData c
          c++
        i = 0
        while i < data[0].length
          c = 0
          while c < buffer.numberOfChannels
            if start <= position < stop
              channels[c][position - start] = data[c][i]
            c++
          position++
          i++
      offline.oncomplete = ->
        #sort out channels
        if start > 0
          #move last {start} samples from the end to the front
          c = 0
          while c < buffer.numberOfChannels
            channels[c] = new Float32Array [...channels[c].slice(channels[c].length - start), ...channels[c].slice(0, channels[c].length - start)]
            c++
        buffer = audio.createBuffer channels.length, channels[0].length, audio.sampleRate
        for channel, i in channels
          buffer.copyToChannel channel, i
        resolve null
      source.buffer = buffer
      source.start 0
      offline.startRendering()
  renderRms: (rmsWav) ->
    await rmsWav.analyze()
    rmsWavData = rmsWav.getRmsData()
    c = 0
    stride = 256
    data = new Float32Array buffer.length
    while c < buffer.numberOfChannels
      buffer.copyFromChannel data, c
      rmsChannel = rmsWavData[Math.min(c, rmsWavData.length - 1)]
      i = 0
      while i < buffer.length
        rmsIndex = Math.floor i / stride
        rmsRatio = (i % stride) / stride
        rms0 = rmsChannel[rmsIndex % rmsChannel.length] or 0
        rms1 = rmsChannel[(rmsIndex + 1) % rmsChannel.length] or 0
        rmsVal = rms1 + (rms0 - rms1) * rmsRatio
        data[i] = data[i] * rmsVal
        i++
      buffer.copyToChannel data, c
      c++
  renderScript: (instructions, seed, _fileName) ->
    waveform = @
    mixarrs = waveform.extractRegion 0, buffer.length
    mix = 0
    fileName = fileName or _fileName
    for instruction in instructions
      continue if not instruction
      if /mix/.test instruction
        [,value] = instruction.match /mix (.*)/
        try
          value = +value
          mix = value / 100
      else if /extract/.test instruction
        regions = waveform.getRegions()
        ProjectManager?.getProject()?.regions[fileName] = []
        i = 0
        while i < regions.length
          start = if i is 0 then 0 else regions[i - 1]
          if regions[i] - start > 100
            try
              arrs = waveform.extractRegion start, regions[i]
              mywav = await Waveform(audio).fromArray arrs
              ProjectManager?.getProject()?.regions[fileName].push
                start: start
                end: regions[i]
                waveform: mywav
          i++
      else if /convolve/.test instruction
        [,name] = instruction.match /convolve (.*)/
        impulseName = name#if /\$/.test(name) then fileName + ':' + name else name
        cbuffer = ProjectManager?.getImpulses()?[impulseName]?.buffer or ProjectManager?.getWaveforms()?[name]?.getBuffer()
        if not cbuffer
          bfile = files[Math.floor(noise.hash(seed++) * files.length)]
          impulse = await Waveform(audio).fromFile bfile
          ProjectManager?.getImpulses()?[impulseName] =
            name: bfile.name
            buffer: impulse.getBuffer()
          cbuffer = ProjectManager?.getImpulses()?[impulseName].buffer
        await waveform.renderEffect (ctx) ->
          convolver = ctx.createConvolver()
          convolver.buffer = cbuffer
          convolver.normalize = true
          convolver
        , waveform.getBuffer().length * 2       
      else if /renderRms/.test instruction
        [,name] = instruction.match /renderRms (.*)/
        rmsWav = ProjectManager?.getWaveforms()?[name]
        if rmsWav
          await waveform.renderRms rmsWav
      else if /->/.test instruction
        await waveform.renderEffect (ctx) ->
          dest = null
          conn = null
          effects = []
          effects = instruction.split(/ *-> */g).map (item, i) ->
            return null if item is 'render'
            [all, name, args] = item.match /(.*?)\((.*?)\)/
            args = args.replace /:[ *]duration(.*?)(,|\})/g, (all, dur) ->
              val = eval(waveform.getBuffer().duration + dur)
              ':' + val + ','
            args = JSON.parse args
            if window[name]
              args.audio = ctx
              effect = window[name] args
            if ctx['create' + name]
              effect = ctx['create' + name]()
              for key, val of args
                if typeof(val) is 'string'
                  effect[key] = val
                else
                  effect[key].value = val
            if effects[i - 1]?.gain or effects[i - 1]?.connect
              (effects[i - 1].gain or effects[i - 1]).connect (effect.gain or effect)
            conn = conn or effect
            dest =  effect
            return effect
            item
          if conn.gain?.connect then conn.gain else conn
      else
        [all, name, args] = instruction.match /(.*?)\((.*?)\)/
        if args
          args = args.split(/, */).map (item) ->
            +(item.trim())
        try
          await waveform[name].call @, args
    if mix > 0
      c = 0
      data = new Float32Array buffer.length
      while c < buffer.numberOfChannels
        buffer.copyFromChannel data, c
        i = 0
        while i < buffer.length
          if i < mixarrs[c].length
            data[i] = (data[i] * mix) + (mixarrs[c][i] * (1 - mix))
          else
            data[i] = data[i] * mix
          i++
        buffer.copyToChannel data, c
        c++
  resize: (factor) ->
    newLength = Math.floor buffer.length * factor
    new Promise (resolve) ->
      offline = new OfflineAudioContext buffer.numberOfChannels, newLength, buffer.sampleRate
      source = offline.createBufferSource()
      source.connect offline.destination
      source.buffer = buffer
      source.playbackRate.value = 1 / factor
      offline.oncomplete = (e) ->
        buffer = e.renderedBuffer
        resolve null
      source.start 0
      offline.startRendering()
  fillBins: ->
    canvas.width = canvas.offsetWidth
    canvas.height = canvas.offsetHeight
    channels = []
    start = Math.floor(view.start * buffer.length)
    stop = Math.floor(view.stop * buffer.length)
    length = stop - start
    c = 0
    data = new Float32Array buffer.length
    while c < buffer.numberOfChannels
      buffer.copyFromChannel data, c
      channels[c] = channels[c] or []
      i = start
      while i <= stop
        binNo = Math.floor((i - start) / length * canvas.width)
        channels[c][binNo] = channels[c][binNo] or [1, -1]
        channels[c][binNo][0] = Math.min data[i], channels[c][binNo][0]
        channels[c][binNo][1] = Math.max data[i], channels[c][binNo][1]
        i++
      c++
  setView: (start, stop) ->
    view.start = start
    view.stop = stop
  getView: -> view
  draw: ->
    ctx = canvas.getContext '2d'
    ctx.clearRect 0, 0, canvas.width, canvas.height
    channelHeight = canvas.height / channels.length / 2
    for channel, c in channels
      ctx.beginPath()
      ctx.strokeStyle = 'black'
      channelY = channelHeight * 2 * c + channelHeight
      ctx.moveTo 0, (channel[0][0] * channelHeight) + channelY
      for bin, i in channel
        continue if not bin
        ctx.lineTo i, (bin[0] * channelHeight) + channelY
        if bin[0] isnt bin[1]
          ctx.lineTo i, (bin[1] * channelHeight) + channelY
      ctx.stroke()
  drawFrequencyData: ->
    ctx = canvas.getContext '2d'
    ctx.clearRect 0, 0, canvas.width, canvas.height
    noFreqs = frequencyData[0].length
    sqHeight = canvas.height / noFreqs
    sqWidth = canvas.width / frequencyData.length
    for frame, x in frequencyData
      for data, y in frame
        ctx.beginPath()
        ctx.fillStyle = 'rgba(0, ' + data + ', 0, 1)'
        ctx.lineWidth = 0
        ctx.fillRect x * sqWidth, canvas.height - (y * sqHeight), sqWidth * 2, sqHeight * 2
  drawRegions: ->
    ctx = canvas.getContext '2d'
    for r in regions
      rx = Math.floor r / buffer.length * canvas.width
      ctx.beginPath()
      ctx.strokeStyle = 'red'
      ctx.moveTo rx, 0
      ctx.lineTo rx, canvas.height
      ctx.stroke()
  setCanvas: (_canvas) -> canvas = _canvas
  getBuffer: -> buffer
  getRegions: -> regions
  getRmsData: -> rmsData
  findZeroCrossing: (position) ->
  extractRegion: (start, stop, channel) ->
    arrs = []
    c = 0
    data = new Float32Array buffer.length
    while c < buffer.numberOfChannels
      if typeof(channel) is 'number' and c isnt channel
        c++
        continue
      arr = new Float32Array stop - start
      buffer.copyFromChannel data, c
      i = start
      while i < stop
        arr[i - start] = data[i]
        i++
      arrs.push arr
      c++
    arrs
  fromWaveform: (_waveform) ->
    arrs = _waveform.extractRegion 0, _waveform.getBuffer().length
    await @fromArray arrs
  fromArray: (arrs) ->
    self = @
    new Promise (resolve) ->
      buffer = audio.createBuffer arrs.length, arrs[0].length, audio.sampleRate
      for arr, i in arrs
        buffer.copyToChannel arr, i
      resolve self
  fromFile: (file) ->
    fileName = file.name
    self = @
    new Promise (resolve) ->
      reader = new FileReader()
      reader.onload = (e) ->
        audio.decodeAudioData reader.result, (_buffer) ->
          buffer = _buffer
          resolve self
      reader.readAsArrayBuffer file
  fromGraph: (_graph, multiplier, offset, tempo, beats) ->
    oversample = 1
    graph = await Graph.fromGraph _graph, multiplier, offset, tempo, beats
    length = graph.getBeats() * (60 / graph.getTempo())
    nosmps = +length * audio.sampleRate * oversample
    oversampled = new Float32Array(nosmps)
    i = 0
    while i < nosmps
      oversampled[i] = await graph.getValue i / nosmps
      i++
    ###
    oswaveform = await Waveform(audio).fromArray [oversampled]
    await oswaveform.renderEffect (ctx) ->
      filter = ctx.createBiquadFilter()
      filter.type = 'lowpass'
      filter.frequency = ctx.sampleRate / oversample
      filter
    , null, 0.1
    [oversampled] = oswaveform.extractRegion 0, oswaveform.getBuffer().length
    i = 0
    arr = new Float32Array(+length * audio.sampleRate)
    currentVal = 0
    currentPos = 0
    while i < nosmps
      if Math.floor(i / oversample) isnt currentPos
        arr[currentPos] = currentVal /oversample
        currentPos++
        currentVal = 0
      currentVal += oversampled[i]
      i++
    arr[currentPos] = currentVal / oversample
    ###
    await Waveform(audio).fromArray [oversampled]
  toBase64: ->
    URL.createObjectURL FileUtils.bufferToWave buffer
  toWave: ->
    FileUtils.bufferToWave buffer
  play: (dest, isloop) ->
    if source
      source.stop()
      source = null
    source = audio.createBufferSource()
    source.buffer = buffer
    source.loop = true if isloop
    source.connect dest or audio.destination
    source.start()
  stop: ->
    if source
      source.stop()
      source = null
  getFrequencyData: -> frequencyData
  getPitchData: -> pitchData
  getChannelData: -> channels
  getValueAtTime: (time) ->
    time = time % 1
    output = []
    c = 0
    while c < buffer.numberOfChannels
      channelData = buffer.getChannelData c
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
    while c < rmsData.length
      channelData = rmsData[c]
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
window.Waveform = Waveform
module.exports = Waveform  