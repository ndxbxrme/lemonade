{app, BrowserWindow, Menu, Notification, ipcMain, dialog} = require 'electron'
{autoUpdater} = require 'electron-updater'
fs = require 'fs-extra'
url = require 'url'
path = require 'path'
Graph = require './components/graph'
encoder = require './components/encoder/encoder'

mainWindow = null
newProject = -> mainWindow.webContents.send 'newProject'
loadProject = ->
  result = await dialog.showOpenDialog({ properties: ['openFile', 'multiSelections'] })
  return if result.cancelled
  file = await fs.readFile result.filePaths[0]
  mainWindow.webContents.send 'loadProject', file
saveProject = -> mainWindow.webContents.send 'saveProject'
showGraph = -> mainWindow.webContents.send 'show', state: 'graph'
showWaveform = -> mainWindow.webContents.send 'show', state: 'waveform'
settingsPath = path.join app.getPath('userData'), 'settings.json'
settings =
  width: 700
  height: 500
ready = ->
  autoUpdater.checkForUpdatesAndNotify()
  applicationMenu = Menu.buildFromTemplate [
    label: 'File'
    submenu: [
      label: 'New Project'
      click: newProject
    ,
      label: 'Load Project'
      click: loadProject
    ,
      label: 'Save Project'
      click: saveProject
    ,
      label: 'Quit'
      click: app.quit
    ]
  ,
    label: 'View'
    submenu: [
      label: 'Graph'
      click: showGraph
    ,
      label: 'Waveform'
      click: showWaveform
    ]
  ,
    label: 'Tools'
    submenu: [
      label: 'Convert Video folder'
      click: ->
        await encoder.convertVideoFolder()
        new Notification
          title: 'Lemonade'
          body: 'Finished processing'
        .show()
    ]
  ]
  Menu.setApplicationMenu applicationMenu
  if await fs.exists settingsPath
    settings = JSON.parse await fs.readFile settingsPath, 'utf8'
  settings.webPreferences = nodeIntegration: true
  settings.show = false
  settings.backgroundColor = '#222222'
  settings.darkTheme = true
  mainWindow = new BrowserWindow settings
  mainWindow.once 'ready-to-show', -> mainWindow.show()
  mainWindow.on 'close', (event) ->
    settings = mainWindow.getBounds()
    fs.writeFile settingsPath, JSON.stringify(settings), 'utf8'
  mainWindow.on 'closed', ->
    mainWindow = null
  mainWindow.loadURL url.format
    pathname: path.join __dirname, 'index.html'
    protocol: 'file:'
    slashes: true
  #mainWindow.openDevTools()
app.on 'ready', ready
app.on 'window-all-closed', ->
  process.platform is 'darwin' or app.quit()
app.on 'activiate', ->
  mainWindow or ready()
  
lastB64 = null
graph = null
renderPos = 0
renderStart = 0
renderEnd = 0
nosmps = 0
rendering = false
stride = 4096
buffer = new Float32Array(stride)
waveforms = []
reset = true
doRender = ->
  if renderPos > renderEnd
    console.log 'stopping render'
    rendering = false
    mainWindow.send 'finishedRender'
    return
  startPos = renderPos
  try
    i = 0
    while i < stride
      buffer[i] = graph.getValue (renderPos++ % nosmps) / nosmps
      i++
    mainWindow.send 'rendered', position: startPos, buffer: buffer, reset: reset
    reset = false
    setTimeout doRender
  catch e
    console.log 'error', e
    mainWindow.send 'finishedRender'
    rendering = false
ipcMain.on 'startRender', (win, data) ->
  return if data.b64 is lastB64
  lastb64 = data.b64
  graph = await Graph.fromBase64 data.b64
  graph.setWaveforms data.waveforms or waveforms
  graph.setBarNo data.bar or 0
  waveforms = data.waveforms if data.waveforms
  renderStart = data.position
  renderPos = renderStart
  renderEnd = data.end or renderStart + data.nosmps
  nosmps = data.nosmps
  reset = true
  console.log 'start render', graph.getText(), rendering
  if not rendering
    console.log 'doing it', data.waveforms
    rendering = true
    doRender()