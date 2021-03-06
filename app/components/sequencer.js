// Generated by CoffeeScript 2.5.1
(function() {
  window.Sequencer = function(audio) {
    var lastTime, loadSample, loadWaveTable, lookahead, mainGain, nextNote, playNote, playing, schedule, startTime, steps, tempo, tracks;
    mainGain = audio.createGain();
    tempo = 120;
    steps = 4;
    lookahead = 0.1;
    lastTime = -1;
    startTime = 0;
    playing = true;
    tracks = [];
    loadSample = async function(uri) {
      var arrayBuffer, audioBuffer, response;
      if (samples[uri]) {
        return;
      }
      response = (await fetch(uri));
      arrayBuffer = (await response.arrayBuffer());
      audioBuffer = (await audio.decodeAudioData(arrayBuffer));
      return samples[uri] = audioBuffer;
    };
    loadWaveTable = async function(name) {
      var data, response;
      if (waveTables[name]) {
        return;
      }
      response = (await fetch('https://ndxbxrme.github.io/yma-full/assets/wave-tables/' + name));
      data = JSON.parse(((await response.text())).replace(/'/g, '"').replace(/\n/g, '').replace(/,\]/g, ']').replace(/,\}/g, '}'));
      return waveTables[name] = audio.createPeriodicWave(data.real, data.imag);
    };
    playNote = function(time, note) {
      var adsr, attackTime, attackValue, decayTime, decayValue, id, length, ref, releaseTime, source, sustainTime, sustainValue;
      source = null;
      if (note.track.instrument.solo) {
        ref = note.track.current;
        for (id in ref) {
          adsr = ref[id];
          adsr.stop();
        }
      }
      attackTime = note.attackTime || note.track.attackTime || 0.001;
      attackValue = note.attackValue || note.track.attackValue || 0.8;
      decayTime = note.decayTime || note.track.decayTime || 0.1;
      decayValue = note.decayValue || note.track.decayValue || attackValue || 0.1;
      sustainTime = note.sustainTime || note.track.sustainTime || 0.5;
      sustainValue = note.sustainValue || note.track.sustainValue || decayValue;
      releaseTime = note.releaseTime || note.track.releaseTime || 0.01;
      if (note.length) {
        length = 60 / (note.track.tempo || seq.getTempo()) * note.length;
        sustainTime = length - attackTime - decayTime;
      }
      source = instruments[note.track.instrument.type]({
        audio: audio,
        note: note
      });
      adsr = ADSR({
        audio: audio,
        time: time,
        osc: source,
        note: note,
        hold: note.track.hold,
        attackTime: attackTime,
        attackValue: attackValue,
        decayTime: decayTime,
        decayValue: decayValue,
        sustainTime: sustainTime,
        sustainValue: sustainValue,
        releaseTime: releaseTime,
        onStop: function(id) {
          note.playing = false;
          return delete note.track.current[id];
        }
      });
      if (!source.constant) {
        source.connect(adsr.gain);
        adsr.gain.connect(note.track.destination);
      }
      note.playing = true;
      return note.track.current[adsr.id] = adsr;
    };
    nextNote = function(track, time) {
      var note;
      if (note = track.notes[track.pointer]) {
        if (note.time < time) {
          track.pointer++;
          return note;
        }
      }
      return null;
    };
    schedule = function() {
      var currentTime, deg, diff, i, len, note, time, timeNow, track;
      if (playing) {
        for (i = 0, len = tracks.length; i < len; i++) {
          track = tracks[i];
          deg = (track.tempo || tempo) / 60;
          currentTime = audio.currentTime - startTime;
          timeNow = (currentTime * deg) % (track.steps || steps);
          time = ((currentTime + lookahead) * deg) % (track.steps || steps);
          if (time < track.lastTime && track.wrap) {
            track.pointer = 0;
          }
          while (note = nextNote(track, time, track.lastTime)) {
            diff = note.time - time;
            playNote(audio.currentTime + lookahead + diff / deg, note);
          }
          track.lastTime = time;
        }
        return window.requestAnimationFrame(schedule);
      }
    };
    return {
      setTempo: function(newTempo) {
        var i, len, results, track;
        tempo = newTempo;
        results = [];
        for (i = 0, len = tracks.length; i < len; i++) {
          track = tracks[i];
          results.push(track.tempo = newTempo);
        }
        return results;
      },
      setSteps: function(newSteps) {
        var i, len, results, track;
        steps = newSteps;
        results = [];
        for (i = 0, len = tracks.length; i < len; i++) {
          track = tracks[i];
          results.push(track.steps = newSteps);
        }
        return results;
      },
      setWrap: function(newWrap) {
        var i, len, results, track;
        results = [];
        for (i = 0, len = tracks.length; i < len; i++) {
          track = tracks[i];
          results.push(track.wrap = newWrap);
        }
        return results;
      },
      setPlayFn: function(fn) {
        return playNote = fn;
      },
      getTracks: function() {
        return tracks;
      },
      getTempo: function() {
        return tempo;
      },
      addTrack: function(wet, dry) {
        var newTrack;
        newTrack = Track({
          tempo: tempo,
          steps: steps,
          audio: audio
        });
        tracks.push(newTrack);
        if (!wet || dry) {
          newTrack.connect(mainGain);
        }
        if (wet) {
          newTrack.connect(wet);
        }
        if (dry) {
          newTrack.connect(dry);
        }
        return newTrack;
      },
      start: function(restart) {
        var i, len, track;
        if (typeof document !== "undefined" && document !== null) {
          document.body.className = document.body.className.replace(/ *seq-playing/g, '') + ' seq-playing';
        }
        if (restart) {
          startTime = audio.currentTime;
          for (i = 0, len = tracks.length; i < len; i++) {
            track = tracks[i];
            track.pointer = 0;
            track.lastTime = -1;
          }
        }
        playing = true;
        return schedule();
      },
      stop: function() {
        var stopAll;
        if (typeof document !== "undefined" && document !== null) {
          document.body.className = document.body.className.replace(/ *seq-playing/g, '');
        }
        playing = false;
        stopAll = function() {
          var adsr, i, len, results, track;
          results = [];
          for (i = 0, len = tracks.length; i < len; i++) {
            track = tracks[i];
            results.push((function() {
              var j, len1, ref, results1;
              ref = track.current;
              results1 = [];
              for (j = 0, len1 = ref.length; j < len1; j++) {
                adsr = ref[j];
                results1.push(adsr.stop());
              }
              return results1;
            })());
          }
          return results;
        };
        stopAll();
        return setTimeout(stopAll, 50); //panic
      },
      load: async function() {
        var i, len, ref, results, track;
        results = [];
        for (i = 0, len = tracks.length; i < len; i++) {
          track = tracks[i];
          results.push((await ((ref = track.instrument) != null ? typeof ref.load === "function" ? ref.load() : void 0 : void 0)));
        }
        return results;
      },
      connect: function(thing) {
        return mainGain.connect(thing);
      }
    };
  };

  module.exports = window.Sequencer;

}).call(this);
