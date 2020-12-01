{ipcRenderer} = require 'electron'
console.log 'hey from renderer'
setTimeout ->
  ProjectManager.init()
, 10
ipcRenderer.on 'newProject', -> ProjectManager.new()
ipcRenderer.on 'loadProject', (win, data) -> 
  console.log 'load project', data, ProjectManager
  ProjectManager.loadZip(data)
ipcRenderer.on 'saveProject', -> ProjectManager.doZip()
ipcRenderer.on 'rendered', (win, data) ->
  ProjectManager.onRendered data
ipcRenderer.on 'finishedRender', (win, data) ->
  ProjectManager.finishedRender()
ipcRenderer.on 'show', (win, data) ->
  ProjectManager.setState data.state
ProjectManager.setRenderFn (b64, waveforms, position, end, nosmps, bar) ->
  ipcRenderer.send 'startRender', b64: b64, waveforms: waveforms, position: position, end: end, nosmps: nosmps, bar: bar