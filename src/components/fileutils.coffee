FileUtils =
  bufferToWave: (mybuffer) ->
    noChan = mybuffer.numberOfChannels
    length = (mybuffer.length) * noChan * 2 + 44
    buffer = new ArrayBuffer length
    view = new DataView buffer
    channels = []
    offset = 0
    pos = 0
    setUint32 = (data) ->
      view.setUint32 pos, data, true
      pos += 4
    setUint16 = (data) ->
      view.setUint16 pos, data, true
      pos += 2
    setUint32 0x46464952
    setUint32 length - 8
    setUint32 0x45564157
    setUint32 0x20746d66
    setUint32 16
    setUint16 1
    setUint16 noChan
    setUint32 mybuffer.sampleRate
    setUint32 mybuffer.sampleRate * 2 * noChan
    setUint16 noChan * 2
    setUint16 16
    setUint32 0x61746164
    setUint32 length - pos - 4
    i = 0
    while i < noChan
      channels.push mybuffer.getChannelData i
      i++
    while pos < length
      i = 0
      while i < noChan
        sample = Math.max -1, Math.min 1, channels[i][offset]
        sample = (if 0.5 + sample < 0 then sample * 32768 else sample * 32768) or 0
        view.setInt16 pos, sample, true
        pos += 2
        i++
      offset++
    new Blob [buffer], type:'audio/wav'
window.JSZip = require 'jszip'
window.FileSaver = require 'file-saver'
window.FileUtils = FileUtils
module.exports = FileUtils