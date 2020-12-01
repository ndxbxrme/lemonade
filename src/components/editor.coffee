modal = require './modal/modal.coffee'
Editor = (audio) ->
  waveform = null
  source = null
  playing = false
  looping = false
  playStart = 0
  duration = 0
  loopDuration = 0
  startPos = 0
  selection = [0,0]
  undoStack = []
  undoPointer = -1
  pushUndo = ->
    while undoStack.length and undoStack.length > undoPointer + 1
      undoStack.pop()
    undoStack.push waveform.extractRegion 0, waveform.getBuffer().length
    undoPointer++
  undo = ->
    undoPointer--
    undoPointer = 0 if undoPointer < 0
    arrs = undoStack[undoPointer]
    waveform = await Waveform(audio).fromArray arrs
    waveform.setCanvas $('.waveditor canvas')
    updateView()
  redo = ->
    undoPointer++
    undoPointer = undoStack.length - 1 if undoPointer >= undoStack.length
    return if undoPointer < 0
    arrs = undoStack[undoPointer]
    waveform = await Waveform(audio).fromArray arrs
    waveform.setCanvas $('.waveditor canvas')
    updateView()
  
  reset = ->
    setPlaying false
    looping = false
    playStart = 0
    duration = 0
    startPos = 0
    selection = [0,0]
    $('.waveditor .padding').style.width = '100%'
    $('.waveditor .waveform-inner').style.left = 0
    $('.waveditor .waveform-holder').scrollLeft = 0
  setPlaying = (_state) ->
    playing = _state
    document?.body.className = document.body.className.replace(/ *editor-playing/g, '')
    if _state
      document?.body.className += ' editor-playing'
  clearUndoHistory = ->
    undoStack = []
    undoPointer = -1
  parkCursor = ->
    if not playing
      $('.waveditor .cursor').style.left =  toViewSpace(startPos) * 100 + '%'
  play = ->
    event?.target.blur()
    if effectBusScript = $('.waveditor #effectBus')?.value.trim()
      effectBus = EffectBus(audio).fromScript effectBusScript
      EffectBus.startGlobal()
    mystop()
    playStart = audio.currentTime
    setPlaying true
    #looping = true
    buffer = waveform.getBuffer()
    duration = buffer.duration
    source = audio.createBufferSource()
    if $('.waveditor #loop').checked
      looping = true
      source.loopStart = selection[0] * duration
      source.loopEnd = if selection[0] is selection[1] then duration else selection[1] * duration
      loopDuration = source.loopEnd - source.loopStart
      source.loop = true
    if effectBus
      source.connect effectBus.destination
      effectBus.connect audio.destination
    else
      source.connect audio.destination
    source.buffer = buffer
    #source.loop = true
    source.start(0, startPos * duration)

  mystop = ->
    event?.target.blur()
    if source and playing
      console.trace 'stopp'
      source.stop()
      #audio.close()
      #audio = new AudioContext()
      setPlaying false
      looping = false
      parkCursor()

  updateView = ->
    waveform.fillBins()
    waveform.draw() if not playing
    view = waveform.getView()
    $('.waveditor .padding').style.width = 1 / (view.stop - view.start) * 100 + '%'
    left = $('.waveditor .padding').offsetWidth * view.start
    $('.waveditor .waveform-holder').scrollLeft = left
    $('.waveform-info .duration').innerText = waveform.getBuffer().duration.toFixed(3) + 's'
    $('.waveform-info .samples').innerText = waveform.getBuffer().length.toFixed(3)
    $('.selection-info .duration').innerText = Math.abs(waveform.getBuffer().duration * (selection[1] - selection[0])).toFixed(3) + 's'
    $('.selection-info .samples').innerText = Math.abs Math.floor waveform.getBuffer().length * (selection[1] - selection[0])
    $('.selection-info .hz').innerText = Math.abs(1 / (waveform.getBuffer().duration * (selection[1] - selection[0]))).toFixed(3) + 'hz'
    drawSelection()
    parkCursor()
  zoomToSelection = ->
    myselection = Array.from selection
    myselection.sort (a, b) -> if a > b then 1 else -1
    waveform.setView myselection[0], myselection[1]
    updateView()
  zoomIn = (mousePos) ->
    view = waveform.getView()
    if typeof mousePos is 'number'
      wavPos = ((view.stop - view.start) * mousePos) + view.start
    dur = view.stop - view.start
    dur *= 0.9
    view.stop = view.start + dur
    #attempt to center startpos
    if not playing
      if wavPos
        view.start = wavPos - ((mousePos or .5) * dur)
        view.stop = wavPos + (1 - (mousePos or .5)) * dur
      else
        center = ((view.stop - view.start) * (mousePos or .5)) + view.start
        diff = startPos - center
        view.start += diff
        view.stop += diff
    if view.stop > 1
      view.stop = 1
      view.start = view.stop - dur 
    if view.start < 0
      view.start = 0
      view.stop = view.start + dur
    waveform.setView view.start, view.stop
    updateView()
  zoomOut = (mousePos) ->
    view = waveform.getView()
    if typeof mousePos is 'number'
      wavPos = ((view.stop - view.start) * mousePos) + view.start
    dur = view.stop - view.start
    dur *= 1.1
    view.stop = view.start + dur
    if not playing
      if wavPos
        view.start = wavPos - ((mousePos or .5) * dur)
        view.stop = wavPos + (1 - (mousePos or .5)) * dur
      else
        center = ((view.stop - view.start) * (mousePos or .5)) + view.start
        diff = startPos - center
        view.start += diff
        view.stop += diff
    if view.stop > 1
      view.stop = 1
      view.start = Math.max 0, view.stop - dur 
    if view.start < 0
      view.start = 0
      view.stop = Math.min 1, view.start + dur
    waveform.setView view.start, view.stop
    updateView()
  zoomFull = ->
    waveform.setView 0, 1
    updateView()
  redraw = ->
    waveform.setCanvas $ '.waveditor canvas'
    waveform.fillBins()
    waveform.draw()

  toViewSpace = (x) ->
    view = waveform.getView()
    (x - view.start) / (view.stop - view.start)
  fromViewSpace = (x) ->
    view = waveform.getView()
    x * (view.stop - view.start) + view.start
  drawSelection = ->
    myselection = Array.from selection
    myselection = myselection.sort (a, b) -> if a > b then 1 else -1
    sElm = $ '.waveditor .selection'
    startPos = myselection[0]
    parkCursor()
    sElm.style.left = toViewSpace(myselection[0]) *  100 + '%'
    sElm.style.width = (toViewSpace(myselection[1]) - toViewSpace(myselection[0])) *  100 + '%'
    $('.selection-info .duration').innerText = (waveform.getBuffer().duration * (selection[1] - selection[0])).toFixed(3) + 's'
    $('.selection-info .samples').innerText = Math.floor waveform.getBuffer().length * (selection[1] - selection[0])
    $('.selection-info .hz').innerText = (1 / (waveform.getBuffer().duration * (selection[1] - selection[0]))).toFixed(3) + 'hz'

  updateCursor = ->
    if playing
      currentPos = (audio.currentTime - playStart + startPos * duration) / duration
      if looping
        if selection and selection.length and selection[0] isnt selection[1]
          myselection = Array.from selection
        else
          myselection = [toViewSpace(0),toViewSpace(1)]
        myselection.sort (a, b) -> if a > b then 1 else -1
        if currentPos > myselection[1]
          currentPos = myselection[0] + (currentPos - myselection[0]) % (myselection[1] - myselection[0])
      else
        if currentPos > 1
          currentPos = startPos
          $('.waveditor .waveform-holder').scrollLeft = startPos * $('.waveditor .waveform-inner').offsetWidth
          setPlaying false
      left = toViewSpace(currentPos)
      if left < 0
        scrollAmount = left * $('.waveditor .waveform-inner').offsetWidth
        $('.waveditor .waveform-holder').scrollLeft += scrollAmount
        left = 0
      else if left > 0.5
        #scroll if necessary
        scrollAmount = (left - 0.5) * $('.waveditor .waveform-inner').offsetWidth
        $('.waveditor .waveform-holder').scrollLeft += scrollAmount
        #left = 0.5
      $('.waveditor .cursor').style.left = left * 100 + '%'
    window.requestAnimationFrame updateCursor
  updateCursor()
  getSelection = (ignoreSameCheck) ->
    if (selection and selection.length and selection[0] isnt selection[1]) or ignoreSameCheck
      mysel = Array.from selection
    else
      mysel = [0, 1]
    mysel.sort (a, b) -> if a > b then 1 else -1
    length = waveform.getBuffer().length
    [Math.floor(mysel[0] * length), Math.floor(mysel[1] * length)]
  process = (c, cb) ->
    view = waveform.getView()
    c = c or 3
    mysel = getSelection()
    arrs = waveform.extractRegion 0, waveform.getBuffer().length
    
    weldLength = 100
    weldStart = waveform.extractRegion mysel[0], mysel[0] + weldLength
    weldEnd = waveform.extractRegion mysel[1] - weldLength, mysel[1]
    
    channel = 0
    while channel < waveform.getBuffer().numberOfChannels
      if c & (channel + 1)
        index = mysel[0]
        while index < mysel[1]
          cb arrs, channel, index, mysel[0], mysel[1]
          index++        
      channel++
    if mysel[0] > 0
      #weld Start
      channel = 0
      while channel < waveform.getBuffer().numberOfChannels
        if c & (channel + 1)
          i = 0
          while i < weldStart[channel].length
            mix = i / weldStart[channel].length
            data = arrs[channel][mysel[0] + i]
            weld = weldStart[channel][i]
            arrs[channel][mysel[0] + i] = (data * mix) + (weld * (1 - mix))
            i++
        channel++
    if mysel[1] < waveform.getBuffer().length
      #weld End
      channel = 0
      while channel < waveform.getBuffer().numberOfChannels
        if c & (channel + 1)
          i = 0
          while i < weldEnd[channel].length
            mix = i / weldEnd[channel].length
            data = arrs[channel][(mysel[1] - weldLength) + i]
            weld = weldEnd[channel][i]
            arrs[channel][(mysel[1] - weldLength) + i] = (weld * mix) + (data * (1 - mix))
            i++
        channel++
    name = waveform.name
    waveform = await Waveform(audio).fromArray arrs
    waveform.setCanvas $('.waveditor canvas')
    waveform.setView view.start, view.stop
    waveform.name = name
    pushUndo()
    updateView()
  selectGraph = (graph) ->
    if not graph
      modalHtml = pug.render $('#modal-graph-select').innerText.replace(/\n  /g,'\n'),
        graphs: Object.keys(ProjectManager.getGraphs())
      try
        await modal.show modalHtml, (resolve, reject) ->
          ProjectManager.submit = ->
            selectedGraph = $('.modal-content .graph-select').value
            graph = ProjectManager.getGraphs()[selectedGraph]
            resolve()
          ProjectManager.cancel = ->
            reject()
        modal.hide()
      catch e
        return
    graph
  init: ->
    window.addEventListener 'keydown', (event) ->
      if event.code is 'Space'
        if playing then mystop()
        else play()
      else if event.code is 'KeyZ'
        zoomToSelection()
  cursorToStart: ->
    currentPos = 0
    startPos = 0
    if not playing
      parkCursor()
    else
      mystop()
      play()
  cursorToEnd: ->
    currentPos = 1
    startPos = 1
    if not playing
      parkCursor()
    else
      mystop()
      play()
  renderGraphClick: ->
    audio = audio or new AudioContext()
    modalHtml = app.pug.render($('script#modal-render-graph').innerText.replace(/\n  /g,'\n'))
    try
      result = await app.modal.show modalHtml, (resolve, reject) ->
        editor.submit = ->
          resolve await app.formValidator.validate '.modal-holder form'
        editor.cancel = reject
    await app.modal.hide()
    @renderGraph result.b64, result.length if result
  renderGraph: (b64, length) ->
    audio = audio or new AudioContext()
    mystop()
    oversample = 8
    graph = await Graph.fromBase64 b64
    fn = graph.fn()
    nosmps = +length * audio.sampleRate * oversample
    oversampled = new Float32Array(nosmps)
    i = 0
    while i < nosmps
      oversampled[i] = await graph.getValue i / nosmps
      i++
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
    waveform = await Waveform(audio).fromArray [arr]
    reset()
    waveform.setCanvas $ '.waveditor canvas'
    updateView()
  mouseDown: ->
    event.preventDefault()
    if event.buttons is 1
      pos = event.layerX / event.target.offsetWidth
      if event.shiftKey
        mypos = fromViewSpace pos
        selection[0] = selection[0] or 0
        selection[1] = selection[1] or 0
        selection[0] = mypos if mypos < selection[0]
        selection[1] = mypos if mypos > selection[0]
      else
        selection[0] = fromViewSpace pos
        selection[1] = fromViewSpace pos
      startPos = selection[0]
      drawSelection()
      if not playing
        parkCursor()
      else
        mystop()
        #set loop position
        play()
  mouseUp: ->
  mouseMove: ->
    if event.buttons is 1
      pos = event.layerX / event.target.offsetWidth
      selection[1] = fromViewSpace pos
      drawSelection()
      #scroll if close to edge
  mouseOut: ->
    #did we leave the right side?
    view = waveform.getView()
    if event.offsetX >= event.target.clientWidth
      selection[1] = view.stop
      drawSelection()
    else if event.offsetX <= 0
      selection[0] = view.start
      drawSelection()
    #if so set selection[1] to view.stop
  click: () ->
    #startPos = event.layerX / event.target.offsetWidth *  100
    #parkCursor()
    #play()
  mouseWheel: ->
    pos = event.layerX / event.target.offsetWidth
    if Math.abs event.deltaY
      if Math.sign(event.deltaY) < 0
        zoomIn pos
      else
        zoomOut pos
    event.preventDefault()
  scroll: ->
    $('.waveditor .waveform-inner').style.left = event.target.scrollLeft + 'px'
    viewStart = event.target.scrollLeft / $('.waveditor .padding').offsetWidth
    view = waveform.getView()
    diff = viewStart - view.start
    viewStop = view.stop + diff
    waveform.setView viewStart, viewStop
    redraw()
    drawSelection()
    if not playing
      parkCursor()
  selectFile: (fileElm) ->
    return if not fileElm or not fileElm.files
    reset()
    clearUndoHistory()
    audio = audio or new AudioContext()
    waveform = await Waveform(audio).fromFile fileElm.files[0]
    waveform.setCanvas $ '.waveditor canvas'
    pushUndo()
    updateView()
  saveFile: ->
    FileSaver.saveAs waveform.toWave(), $('.waveditor .name').value + '.wav'
  selectWaveform: (name, _waveform, tags) ->
    reset()
    clearUndoHistory()
    $('.waveditor .name').value = name
    waveform = _waveform
    waveform.name = name
    waveform.setCanvas $ '.waveditor canvas'
    document.querySelectorAll('.waveditor .tags option').forEach (item) ->
      item.selected = false
      item.selected = true if tags and tags.includes item.innerText
    pushUndo()
    updateView()
  play: play
  stop: mystop
  zoomToSelection: zoomToSelection
  zoomIn: zoomIn
  zoomOut: zoomOut
  zoomFull: zoomFull
  normalize: ->
    await waveform.normalize()
    pushUndo()
    redraw()
  rectify: ->
    await waveform.rectify()
    pushUndo()
    redraw()
  topDeck: ->
    await waveform.topDeck()
    pushUndo()
    redraw()
  onlyTops: ->
    await waveform.onlyTops()
    pushUndo()
    waveform.fillBins()
    waveform.draw()
  extractSelection: ->
    if selection[0] isnt selection[1]
      selection.sort (a, b) -> if a > b then 1 else -1
      length = waveform.getBuffer().length
      start = Math.floor(fromViewSpace(selection[0]) * length)
      stop = Math.floor(fromViewSpace(selection[1]) * length)
      arrs = waveform.extractRegion start, stop
      if xfade = $('.waveditor .xfade')?.value
        stop++
        xfadearrs = waveform.extractRegion stop, stop + +xfade
        for xfadechannel, c in xfadearrs
          for xfadesample, i in xfadechannel
            arrs[c][i] = arrs[c][i] * (i / xfadechannel.length) + xfadesample * (1 - i / xfadechannel.length)
      #undo
      reset()
      waveform = await Waveform(audio).fromArray arrs
      waveform.setCanvas $('.waveditor canvas')
      pushUndo()
      updateView()
  deleteSelection: ->
    if selection[0] isnt selection[1]
      selection.sort (a, b) -> if a > b then 1 else -1
      length = waveform.getBuffer().length
      start = Math.floor(fromViewSpace(selection[0]) * length)
      stop = Math.floor(fromViewSpace(selection[1]) * length)
      startArrs = waveform.extractRegion 0, start
      endArrs = waveform.extractRegion stop, length
      arrs = new Array(waveform.getBuffer().numberOfChannels)
      c = 0
      while c < arrs.length
        outArr = new Float32Array(startArrs[c].length + endArrs[c].length)
        index = 0
        j = 0
        while j < startArrs[c].length
          outArr[index++] = startArrs[c][j]
          j++
        j = 0
        while j < endArrs[c].length
          outArr[index++] = endArrs[c][j]
          j++
        arrs[c] = outArr
        c++
      reset()
      waveform = await Waveform(audio).fromArray arrs
      waveform.setCanvas $('.waveditor canvas')
      pushUndo()
      updateView()
  extractChannel: (c) ->
    tmparrs = waveform.extractRegion 0, waveform.getBuffer().length
    arrs = []
    arrs.push tmparrs[Math.min(c, waveform.getBuffer().numberOfChannels - 1)]
    reset()
    waveform = await Waveform(audio).fromArray arrs
    waveform.setCanvas $('.waveditor canvas')
    pushUndo()
    updateView()
  setLoopStart: ->
    arrs = []
    mysel = getSelection true
    startArrs = waveform.extractRegion 0, mysel[0]
    endArrs = waveform.extractRegion mysel[0], waveform.getBuffer().length
    c = 0
    while c < startArrs.length
      arrs.push Float32Array.from [...endArrs[c], ...startArrs[c]]
      c++
    waveform = await Waveform(audio).fromArray arrs
    waveform.setCanvas $('.waveditor canvas')
    pushUndo()
    updateView()
  resize: ->
    factor = +$('.resize-factor').value
    await waveform.resize factor
    pushUndo()
    updateView()
  mute: (c) ->
    process c, (arrs, c, index, start, stop) ->
      arrs[c][index] = 0
  fadeIn: (c) ->
    process c, (arrs, c, index, start, stop) ->
      arrs[c][index] = arrs[c][index] * ((index - start) / (stop - start))
  fadeOut: (c) ->
    process c, (arrs, c, index, start, stop) ->
      arrs[c][index] = arrs[c][index] * (1 - ((index - start) / (stop - start)))
  declack: (c) ->
    fade = 5
    process c, (arrs, c, index, start, stop) ->
      arrs[c][index] = arrs[c][index] * Math.min(index / fade, Math.min(1 - ((x - (stop - fade)) / fade), 1))
  smooth: (c) ->
    factor = 0.1
    process c, (arrs, c, index, start, stop) ->
      last = arrs[c][index - 1] or 0
      curr = arrs[c][index]
      dist = curr - last
      if Math.abs dist > factor
        arrs[c][index] = last + Math.sign(dist) * factor
  reverse: (c) ->
    process c, (arrs, c, index, start, stop) ->
      halfway = start + (stop - start) * .5
      if index < halfway
        tmp1 = arrs[c][index]
        tmp2 = arrs[c][(stop - (index - start)) - 1]
        arrs[c][index] = tmp2
        arrs[c][(stop - (index - start)) - 1] = tmp1
  gainFromGraph: (c, graph) ->
    graph = await selectGraph graph
    return if not graph
    process c, (arrs, c, index, start, stop) ->
      arrs[c][index] = arrs[c][index] * graph.getValue((index - start) / (stop - start))
  waveshapeFromGraph: (c, graph) ->
    graph = await selectGraph graph
    return if not graph
    process c, (arrs, c, index, start, stop) ->
      arrs[c][index] = graph.getValue(arrs[c][index])
  swapChannels: ->
    process c, (arrs, c, index, start, stop) ->
      if c is 0
        tmp1 = arrs[0][index]
        tmp2 = arrs[1][index]
        arrs[0][index] = tmp2
        arrs[1][index] = tmp1
      
  renderScript: ->
    ProjectManager?.setWorking()
    seed = ProjectManager?.getProject()?.seed or 200
    scriptText = $('.waveditor .script').value.trim()
    scriptText = scriptText.replace /\n[ +]/g, ''
    instructions = scriptText.split '\n'
    await waveform.renderScript instructions, seed, waveform.name
    waveform.setCanvas $('.waveditor canvas')
    pushUndo()
    updateView()
    ProjectManager?.clearWorking()
  getWaveform: ->
    waveform
  setAudio: (_audio) -> audio = _audio
  saveWaveform: ->
    ProjectManager.saveWaveform $('.waveditor .name').value, waveform, Array.from(document.querySelectorAll('.waveditor .tags option')).reduce (result, item) ->
      result.push item.innerText if item.selected
      result
    , []
  undo: undo
  redo: redo
  currentWaveform: ->
    waveform
  hasWaveform: ->
    waveform isnt null
  clearWaveform: ->
    waveform = null
  waveformName: -> waveform?.name

window.Editor = Editor
module.exports = Editor