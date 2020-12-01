pathToFfmpeg = require 'ffmpeg-static'
ffmpeg = require 'fluent-ffmpeg'
glob = require 'glob'
path = require 'path'
fs = require 'fs-extra'
ffmpeg.setFfmpegPath pathToFfmpeg
console.log pathToFfmpeg
oggFromMkv = (input, output) ->
  new Promise (resolve, reject) ->
    ffmpeg input
    .noVideo()
    .audioCodec 'libvorbis'
    .audioBitrate 128
    .output output
    .on 'end', ->
      resolve()
    .run()

module.exports = 
  convertVideoFolder: -> 
    new Promise (resolve, reject) ->
      glob 'C://Users/lewis/Videos/*.mkv', (err, files) ->
        for file in files
          parsed = path.parse file
          await oggFromMkv file, path.join parsed.dir, parsed.name + '.ogg'
          await fs.unlink file
        resolve()
        