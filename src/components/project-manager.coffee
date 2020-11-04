modal = require './modal/modal.coffee'
Editor = require './editor.coffee'
CodeMirror = require 'codemirror'
require 'codemirror/mode/javascript/javascript'
require 'codemirror/addon/fold/foldcode'
require 'codemirror/addon/fold/foldgutter'
require 'codemirror/addon/fold/brace-fold'
pug = require 'pug'
selectedFile = null
selectedRegion = null
selectedGraph = null
graphWaveform = null
graphPlaying = false
processor = null
files = []
waveforms = {}
impulses = {}
graphs = {}
project = null
audio = null
editor = Editor()
state = null
window.editor = editor
document.body.onclick = ->
  audio = audio or new AudioContext()
  editor?.setAudio audio
  Brain?.setAudio audio

readTextFile = (blob) ->
  new Promise (resolve) ->
    reader = new FileReader()
    reader.onload = (e) ->
      resolve e.target.result
    reader.readAsText blob
addFile = (file) ->
  [prevfile] = files.filter (item) -> item.name is file.name
  return if prevfile
  Object.defineProperty file, 'name',
    writable: true
    value: file.name.replace /\.wav/, ''
  addWaveform = ->
    waveforms[file.name] = await Waveform(audio).fromFile file
    waveforms[file.name].setCanvas $ 'canvas.thumbnail'
    waveforms[file.name].fillBins()
    waveforms[file.name].draw()
    [pfile] = project.files.filter (item) -> item.name is file.name
    console.log 'pfile', pfile
    pfile?.b64 = $('canvas.thumbnail').toDataURL()
  if project.filesLoaded
    files.push file
    project.files.push 
      name: file.name
    await addWaveform()
  else
    [pfile] = project.files.filter (item) -> item.name is file.name
    if pfile
      files.push file
      await addWaveform()


renderFileList = ->
  $('.file-list').innerHTML = ''
  fileFilter = $('.file-filter select').value
  myfiles = project.files.filter (item) ->
    return true if fileFilter is 'All'
    item.tags?.includes fileFilter
  for file in myfiles
    $('.file-list').innerHTML += pug.render $('#file-item').innerText.replace(/\n  /g,'\n'),
      pm: self
      file: file
renderRegionList = ->
  return if not selectedFile
  regions = project.regions[selectedFile]
  $('.region-list').innerHTML = ''
  for region in regions?
    $('.region-list').innerHTML += pug.render $('#region-item').innerText.replace(/\n  /g,'\n'),
      region: region
renderProject = ->
  $('#' + elm)?.value = val for elm, val of project
  renderFileList()
  ProjectManager.renderGraphList()
getProjectJSON = ->
  regions = {}
  for key, val of project.regions
    regions[key] = []
    for region in val
      regions[key].push
        start: region.start
        end: region.end
        duration: region.waveform.getBuffer().duration
        pitchData: region.waveform.getPitchData()
  mygraphs = {}
  for key, graph of graphs
    mygraphs[key] =
      b64: graph.toBase64()
      tags: JSON.stringify graph.tags
  myproject =
    id: $('#id')?.value or Math.floor(Math.random() * 9999999).toString(36)
    files: project.files.map (item) -> {name: item.name, tags: item.tags}
    script: $('#script').value
    name: $('#name').value
    seed: +$('#seed').value
    regions: regions
    graphs: mygraphs
  myproject
clearFiles = ->
  waveforms = {}
  impulses = {}
  files = []
  $('.graph-filter select').value = 'All'
  $('.file-filter select').value = 'All'
  editor.clearWaveform()
  selectedGraph = null
newFn = ->
  clearFiles()
  graphs = {}
  project =
    id: Math.floor(Math.random() * 9999999).toString(36)
    files: []
    regions: {}
    script: 'normalize()\nanalyze()\nextract()'
    name: 'New project'
    seed: 260
    filesLoaded: true
  renderProject()
load = ->
  clearFiles()
  project = JSON.parse $('#io').value
  graphs = {}
  for name, graph of project.graphs
    graphs[name] = await Graph.fromBase64 graph.b64
    graphs[name].tags = JSON.parse graph.tags
    graphs[name].name = name
  project.filesLoaded = not project.files or project.files.length is 0
  renderProject()
save = ->
  myproject = getProjectJSON()
  $('#id').value = myproject.id
  $('#io').value = JSON.stringify myproject
  localStorage.setItem 'classifier:currentProject', JSON.stringify myproject
setState = (newState) ->
  newState = newState or state
  document.body.className = document.body.className.replace(/ *haswaveform| *hasgraph/g, '')
  document.body.className += ' haswaveform' if ProjectManager.hasWaveform()
  document.body.className += ' hasgraph' if ProjectManager.hasGraph()
  document.body.className = document.body.className.replace(/ *\bstate\w+/g, '')
  document.body.className += ' state' + newState
  state = newState
setDrawerState = (newState) ->
  document.body.className = document.body.className.replace(/ *\bdrawerstate\w+/g, '')
  document.body.className += ' drawerstate' + newState

graphEditor = null
init = ->
  myproject = localStorage.getItem 'classifier:currentProject'
  if myproject
    $('#io').value = myproject
    load()
  else
    newFn()
  setState 'brain'
  setDrawerState 'files'
  graphEditor = CodeMirror.fromTextArea $('.graph-editor .fn'),
    mode: 'javascript'
    lineWrapping: true
    lineNumbers: true
    foldGutter: true
    gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"]
  #graphEditor.foldCode()
  graphEditor.on 'change', @renderGraph
  console.log graphEditor
  ###
  modalHtml = pug.render $('#modal-welcome').innerText.replace(/\n  /g,'\n')
  await modal.show modalHtml, (resolve, reject) ->
    ProjectManager.newProject = ->
      ProjectManager.new()
      resolve()
    ProjectManager.openZip = (fileElm) ->
      ProjectManager.chooseFile fileElm
      resolve()
  modal.hide()
  ###
graphTimeout = null
setGraphPlaying = (_state) ->
  playing = _state
  document?.body.className = document.body.className.replace(/ *graph-playing/g, '')
  try
    clearTimeout graphTimeout
  if _state
    document?.body.className += ' graph-playing'
#setTimeout init
ProjectManager =
  setState: setState
  saveWaveform: (name, _waveform, tags) ->
    waveforms[name] = _waveform
    waveforms[name].setCanvas $ 'canvas.thumbnail'
    waveforms[name].fillBins()
    waveforms[name].draw()
    b64 = $('canvas.thumbnail').toDataURL()
    [pfile] = project.files.filter (item) -> item.name is name
    if pfile
      pfile.tags = tags
      pfile.b64 = b64
    else
      project.files.push
        name: name
        tags: tags
        b64: b64
    renderFileList()
    renderRegionList()
  loadZip: (data) ->
    audio = audio or new AudioContext()
    clearFiles()
    zip = await JSZip.loadAsync data
    for key, zfile of zip.files
      if key is 'project.json'
        u8 = await zfile.async 'blob'
        text = await readTextFile u8
        $('#io').value = text
        load()
    for key, zfile of zip.files
      if /\.wav$/.test key
        u8 = await zfile.async 'blob'
        myfile = new File [u8], key
        await addFile myfile
    [unloaded] = project.files.filter (item) ->
      [myfile] = files.filter (itemf) -> itemf.name is item.name
      not myfile
    project.filesLoaded = not unloaded
    renderFileList()
  chooseFile: (fileElm) ->
    return if not fileElm.files or not fileElm.files.length
    audio = audio or new AudioContext()
    if /application\/.*zip.*/.test fileElm.files[0].type
      #modalHtml = pug.render $('#modal-load-zip').innerText.replace(/\n  /g,'\n')
      #result = await modal.show modalHtml, (resolve) ->
      #  ProjectManager.openZip = ->
      clearFiles()
      zip = await JSZip.loadAsync fileElm.files[0]
      for key, zfile of zip.files
        if key is 'project.json'
          u8 = await zfile.async 'blob'
          text = await readTextFile u8
          $('#io').value = text
          load()
      for key, zfile of zip.files
        if /\.wav$/.test key
          u8 = await zfile.async 'blob'
          myfile = new File [u8], key
          await addFile myfile
      #    resolve()
      #modal.hide()
    else
      for file in fileElm.files
        await addFile file
    [unloaded] = project.files.filter (item) ->
      [myfile] = files.filter (itemf) -> itemf.name is item.name
      not myfile
    project.filesLoaded = not unloaded
    renderFileList()
    #files = fileElm.files
  renderScript: ->
    #render everything up to and including extract
    seed = +$('#seed').value
    document.body.className = document.body.className.replace(/ *working/g, '') + ' working'
    scriptText = $('#script').value.trim()
    [preText, postText] = scriptText.split /extract.*?\n/
    preText += '\nextract()' if postText
    preText = preText.replace /\n[ +]/g, ''
    postText = postText.replace /\n[ +]/g, '' if postText
    instructions = preText.split('\n')
    for file, fileNo in files
      waveforms[file.name] = waveform = await Waveform(audio).fromFile file
      await waveform.renderScript instructions, seed, file.name
      min = 9999999
      max = -9999999
      for frame, i in waveform.getFrequencyData()
        for item in frame
          min = Math.min item, min
          max = Math.max item, max
        #render everything after the extract line
      waveform.setCanvas $ 'canvas'
      waveform.fillBins()
      waveform.draw()
      #waveform.drawRegions()
    #render regions
    if postText
      instructions = postText.split('\n')
      for key, regions of project.regions
        for region, regionNo in regions
          await region.waveform.renderScript instructions, seed
    document.body.className = document.body.className.replace(/ *working/g, '')
  init: init
  new: newFn
  load: load
  save: save
  setWorking: ->
    document.body.className = document.body.className.replace(/ *working/g, '') + ' working'
  clearWorking: ->
    document.body.className = document.body.className.replace(/ *working/g, '')
  renderProject: renderProject
  renderFileList: renderFileList
  clearFiles: clearFiles
  fileClass: (fileName) ->
    className = ''
    [file] = files.filter (item) -> item.name is fileName
    className += ' loaded' if file
    className += ' selected' if fileName is selectedFile
    className
  regionClass: (region) ->
    className = ''
    className += ' selected' if region.start.toString() is selectedRegion?.toString()
  selectFile: (fileName) ->
    try
      editor.stop()
    try
      @stopGraph()
    selectedFile = fileName
    ###
    selectedRegion = null
    #copy to current waveform
    currentWaveform = await Waveform(audio).fromWaveform waveforms[selectedFile]
    currentWaveform.setCanvas $ 'canvas'
    currentWaveform.fillBins()
    currentWaveform.draw()
    ###
    [pfile] = project.files.filter (item) -> item.name is fileName
    mywav = await Waveform(audio).fromWaveform waveforms[selectedFile]
    mywav.name = fileName
    editor.selectWaveform fileName, mywav, pfile?.tags
    setState 'waveform'
    renderFileList()
    renderRegionList()
  selectRegion: (regionName) ->
    selectedRegion = regionName.innerText
    [region] = project.regions[selectedFile].filter (item) -> item.start.toString() is selectedRegion
    region.waveform.play() if region
    renderRegionList()
  playSelectedFile: ->
    waveforms[selectedFile].play()
  stop: ->
  doZip: ->
    zip = new JSZip()
    myproject = getProjectJSON()
    zip.file 'project.json', JSON.stringify myproject, null, '  '
    for key, waveform of waveforms
      zip.file key + '.wav', waveform.toWave()
    content = await zip.generateAsync type:'blob'
    FileSaver.saveAs content, 'lemonade-' + myproject.name + '.zip'
  #processScript: processScript
  getProject: -> project
  getImpulses: -> impulses
  getWaveforms: -> waveforms
  getGraphs: -> graphs
  getFiles: -> files
  renderGraphList: ->
    $('.graph-list').innerHTML = ''
    graphFilter = $('.graph-filter select').value
    mygraphs = Object.values(graphs).filter (item) ->
      return true if graphFilter is 'All'
      item.tags?.includes graphFilter
    for graph in mygraphs
      console.log $('#graph-item').innerText.replace(/\n  /g,'\n')
      $('.graph-list').innerHTML += pug.render $('#graph-item').innerText.replace(/\n  /g,'\n'),
        pm: self
        graph: graph.name
    for graph in mygraphs
      graph.setCanvas $('.graph-list #g_' + graph.name.replace(/[^\w_-]/g, 'xx') + ' canvas')
      graph.draw()
  renderGraphControls: ->
    $('.graph-editor .name').value = selectedGraph.name or 'changeme'
    $('.graph-editor .range').value = JSON.stringify(selectedGraph.getRange()) or '{"h":[0,1],"v":[-1,1]}'
    $('.graph-editor .multiplier').value = selectedGraph.getMultiplier() or 1
    $('.graph-editor .offset').value = selectedGraph.getOffset() or 0
    $('.graph-editor .tempo').value = selectedGraph.getTempo() or 60
    $('.graph-editor .beats').value = selectedGraph.getBeats() or 1
    $('.graph-editor .fn').value = selectedGraph.getText() or 'return Math.sin(x * Math.PI * 2)'
    graphEditor.setValue $('.graph-editor .fn').value
  renderGraph: ->
    graphChanged = true
    ge = $ '.graph-editor'
    return if not graphEditor.getValue()
    return if event?.keyCode is 17
    try
      fnVal = graphEditor.getValue() #$('.fn', ge).value
      if fnVal.length < 10
        throw 'errror'
      data = JSON.parse atob fnVal
      graph = await Graph data.text, data.multiplier, data.offset, data.range, data.tempo, data.beats
      selectedGraph = graph
      @renderGraphControls()
    catch e
      try
        graph = await Graph graphEditor.getValue(), $('.multiplier', ge).value, $('.offset', ge).value, JSON.parse($('.range', ge).value), $('.tempo', ge).value, $('.beats', ge).value
      catch ge
        console.log 'caught one', ge.message
    graph.name = $('.name', ge).value
    graph.setCanvas $('canvas', ge)
    try
      graph.draw()
    catch e
      console.log 'caught another', e.message
    selectedGraph = graph
  newGraph: ->
    selectedGraph = await Graph()
    @renderGraphControls()
    @renderGraph()
    setState 'graph'
  saveGraph: ->
    name = $('.graph-editor .name').value
    selectedGraph.name = name
    selectedGraph.tags = Array.from(document.querySelectorAll('.graph-editor .tags option')).reduce (result, item) ->
      result.push item.innerText if item.selected
      result
    , []
    graphs[name] = selectedGraph
    @renderGraphList()
  selectGraph: (name) ->
    try
      editor.stop()
    try
      @stopGraph()
    selectedGraph = graphs[name]
    document.querySelectorAll('.graph-editor .tags option').forEach (item) ->
      item.selected = false
      item.selected = true if selectedGraph.tags and selectedGraph.tags.includes item.innerText
    setState 'graph'
    @renderGraphControls()
    @renderGraph()
  playGraph: ->
    audio = audio or new AudioContext()
    length = selectedGraph.getBeats() * (60 / selectedGraph.getTempo())
    nosmps = +length * audio.sampleRate
    stride = 1024
    processor = processor or audio.createScriptProcessor stride, 1, 1
    processor.connect audio.destination
    position = +$('.graph-startpos')?.value * nosmps
    graphPlaying = true
    processor.onaudioprocess = (e) ->
      c = 0
      while c < 1
        data = e.outputBuffer.getChannelData c
        i = 0
        while i < stride
          data[i] = if not graphPlaying then 0 else selectedGraph.getValue (position++ % nosmps) / nosmps
          i++
        c++
    setGraphPlaying true
    ###
    
    
    
    
    
    graphWaveform = if graphChanged then graphWaveform else await Waveform(audio).fromGraph selectedGraph
    graphChanged = false
    graphWaveform.play null, $('#graph-loop').checked
    setGraphPlaying true
    if not $('#graph-loop').checked
      length = selectedGraph.getBeats() * (60 / selectedGraph.getTempo()) * 1000
      graphTimeout = setTimeout ->
        setGraphPlaying false
      , length
    ###
  stopGraph: ->
    graphWaveform?.stop()
    graphPlaying = false
    setGraphPlaying false
  renderGraphToWaveform: ->
    audio = audio or new AudioContext()
    graphWaveform = await Waveform(audio).fromGraph selectedGraph
    graphWaveform.setCanvas $ 'canvas.thumbnail'
    graphWaveform.fillBins()
    graphWaveform.draw()
    b64 = $('canvas.thumbnail').toDataURL()
    name = 'Graph_' + $('.graph-editor .name').value
    project.files.push 
      name: name
      b64: b64
    waveforms[name] = graphWaveform
    renderFileList()
  deleteWaveform: (name) ->
    name = name or editor.waveformName()
    console.log 'deleting', name
    project.files = project.files.filter (item) -> item.name isnt name
    files = files.filter (item) -> item.name isnt name
    console.log 'w1', waveforms
    delete waveforms[name]
    console.log 'w2', waveforms
    if editor.waveformName() is name
      editor.clearWaveform()
      setState()
    renderFileList()
  renameWaveform: (oldname, newname) ->
    oldname = oldname or editor.waveformName()
    newname = newname or $('.waveditor .name').value
    mywaveform = waveforms[oldname]
    [myfile] = project.files.filter (item) -> item.name is oldname
    project.files = project.files.filter (item) -> item.name isnt oldname
    files = files.filter (item) -> item.name isnt oldname
    delete waveforms[name]
    waveforms[newname] = mywaveform
    mywaveform.name = newname
    editor.selectWaveform newname, mywaveform, myfile?.tags
    project.files.push
      name: newname
    renderFileList()
  deleteGraph: (name) ->
    name = name or selectedGraph.name
    delete graphs[name]
    if selectedGraph.name is name
      selectedGraph = null
      setState()
    renderFileList()
    @renderGraphList()
  renameGraph: (oldname, newname) ->
    oldname = oldname or selectedGraph.name
    newname = newname or $('.graph-editor .name').value
    mygraph = graphs[oldname]
    delete graphs[oldname]
    graphs[newname] = mygraph
    mygraph.name = newname
    @renderGraphList()
    @renderGraphControls()
  hasGraph: ->
    selectedGraph isnt null
  clearGraph: ->
    selectedGraph = null
    setState()
  hasWaveform: ->
    editor.hasWaveform()
  clearWaveform: ->
    editor.clearWaveform()
    setState()
  currentWaveform: ->
    editor.currentWaveform()
  setState: setState
  setDrawerState: setDrawerState
  setSeed: (_seed) ->
    project.seed = _seed
window.ProjectManager = ProjectManager
module.exports = ProjectManager
