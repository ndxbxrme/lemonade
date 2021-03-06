// Generated by CoffeeScript 2.5.1
(function() {
  var samples, waveTables;

  waveTables = {};

  samples = {};

  window.instruments = {
    Osc1x: function(opts) {
      var gain, osc, ref;
      gain = opts.audio.createGain();
      osc = opts.audio.createOscillator();
      osc.frequency.value = opts.note.freq || ((ref = notesByMIDINo[opts.note.noteNo]) != null ? ref.freq : void 0) || notesByName[opts.note.noteName];
      if (opts.note.track.instrument.periodicWave) {
        osc.setPeriodicWave(waveTables[opts.note.track.instrument.periodicWave]);
      }
      osc.connect(gain);
      if (opts.note.gain) {
        gain.gain.value = opts.note.gain;
      }
      return {
        load: async function(name) {
          var data, response;
          name = name || opts.name;
          if (waveTables[name]) {
            return;
          }
          response = (await fetch('https://ndxbxrme.github.io/yma-full/assets/wave-tables/' + name));
          data = JSON.parse(((await response.text())).replace(/'/g, '"').replace(/\n/g, '').replace(/,\]/g, ']').replace(/,\}/g, '}'));
          return waveTables[name] = audio.createPeriodicWave(data.real, data.imag);
        },
        connect: function(thing) {
          return gain.connect(thing);
        },
        start: function(time) {
          return osc.start(time);
        },
        stop: function(time) {
          return osc.stop(time);
        }
      };
    },
    Sample: function(opts) {
      var gain, source;
      gain = opts.audio.createGain();
      source = opts.audio.createBufferSource();
      source.buffer = samples[opts.note.track.instrument.sample];
      if (opts.note.playbackRate || opts.note.track.instrument.playbackRate) {
        source.playbackRate.setValueAtTime(opts.note.playbackRate || opts.note.track.instrument.playbackRate, opts.audio.currentTime);
      }
      if (opts.note.gain) {
        gain.gain.value = opts.note.gain;
      }
      source.connect(gain);
      return {
        load: async function(uri) {
          var arrayBuffer, audioBuffer, response;
          if (samples[uri]) {
            return;
          }
          response = (await fetch(uri));
          arrayBuffer = (await response.arrayBuffer());
          audioBuffer = (await audio.decodeAudioData(arrayBuffer));
          return samples[uri] = audioBuffer;
        },
        connect: function(thing) {
          return gain.connect(thing);
        },
        start: function(time) {
          return source.start(time);
        },
        stop: function(time) {
          return source.stop(time);
        }
      };
    },
    Waveform: function(opts) {
      var gain, source;
      gain = opts.audio.createGain();
      source = opts.audio.createBufferSource();
      source.buffer = opts.note.track.instrument.waveform.getBuffer();
      if (opts.note.playbackRate || opts.note.track.instrument.playbackRate) {
        source.playbackRate.setValueAtTime(opts.note.playbackRate || opts.note.track.instrument.playbackRate, opts.audio.currentTime);
      }
      if (opts.note.gain) {
        gain.gain.value = opts.note.gain;
      }
      source.connect(gain);
      return {
        connect: function(thing) {
          return gain.connect(thing);
        },
        start: function(time) {
          return source.start(time);
        },
        stop: function(time) {
          return source.stop(time);
        }
      };
    },
    WaveformConst: function(opts) {
      var gain, source;
      if (!opts.note.track.source) {
        opts.note.track.constant = true;
        opts.note.track.source = source = opts.audio.createBufferSource();
        source.buffer = opts.note.track.instrument.waveform.getBuffer();
        source.loop = true;
        opts.note.track.gain = gain = opts.audio.createGain();
        source.connect(gain);
        gain.connect(opts.note.track.destination);
      }
      if (opts.note.playbackRate || opts.note.track.instrument.playbackRate) {
        source.playbackRate.setValueAtTime(opts.note.playbackRate || opts.note.track.instrument.playbackRate, opts.audio.currentTime);
      }
      return {
        constant: true,
        start: function(time) {
          return null;
        },
        stop: function(time) {
          return source.stop(time);
        }
      };
    }
  };

  module.exports = window.instruments;

}).call(this);
