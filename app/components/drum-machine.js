// Generated by CoffeeScript 2.5.1
(function() {
  var DrumMachine;

  DrumMachine = function(audio, seq) {
    var makeBar, stabilityHits, tracks;
    tracks = [];
    stabilityHits = {
      kick: {
        regular: [[1, 0, 1, 0], [1, 0, 0, 0], [1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0]],
        halftime: [[1, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0]]
      },
      snare: {
        regular: [[0, 1, 0, 1], [0, 1, 0, 0], [0, 0, 0, 0]],
        halftime: [[0, 0, 1, 0], [0, 0, 1, 0], [0, 0, 0, 0]]
      }
    };
    makeBar = function(seed, track, steps, start) {
      var exclude, excludeGroup, foundNote, i, j, len, ref, ref1, ref2, ref3;
      i = 0;
      while (i < steps) {
        if (noise.hash(seed++) < ((ref = track.graphs.trigger) != null ? ref.getValue(i / steps) : void 0) * ((ref1 = track.graphs.busyness) != null ? ref1.getValue((start + i) / track.steps) : void 0)) {
          if (track.exclude) {
            console.log('got exclude');
            //get all tracks from exclude group
            foundNote = false;
            excludeGroup = tracks.filter(function(item) {
              return item.exclude === track.exclude;
            });
            if (excludeGroup.length) {
              for (j = 0, len = excludeGroup.length; j < len; j++) {
                exclude = excludeGroup[j];
                [foundNote] = exclude.notes.filter(function(item) {
                  return item.time === start + i;
                });
                console.log('found note', foundNote);
                if (foundNote) {
                  break;
                }
              }
            }
          }
          //continue if foundNote
          if (!foundNote) {
            console.log(track.dmType, start + i);
            track.addNote({
              time: start + i,
              length: 1,
              gain: (((ref2 = track.graphs.gain) != null ? ref2.getValue(i / steps) : void 0) || 1) * ((ref3 = track.graphs.dynamics) != null ? ref3.getValue((start + i) / track.steps) : void 0)
            });
          }
        }
        i += 1 / 2 / 2;
      }
      return seed;
    };
    return {
      addTrack: function(opts) {
        var track;
        track = seq.addTrack();
        track.instrument = {
          type: 'Waveform',
          waveform: opts.waveform
        };
        track.steps = 0;
        track.dmType = opts.type;
        if (opts.destination) {
          track.destination = opts.destination;
        }
        track.graphs = opts.graphs;
        if (opts.exclude) {
          track.exclude = opts.exclude;
        }
        return tracks.push(track);
      },
      getTracks: function() {
        return tracks;
      },
      setSteps: function(steps) {
        var j, len, results, track;
        results = [];
        for (j = 0, len = tracks.length; j < len; j++) {
          track = tracks[j];
          results.push(track.steps = steps);
        }
        return results;
      },
      addBar: function(seeds, start, barNo, steps) {
        var hit, hits, i, j, k, l, len, len1, len2, mybar, ref, ref1, ref2, ref3, ref4, results, seed, track;
        seed = seeds[barNo % seeds.length];
        for (j = 0, len = tracks.length; j < len; j++) {
          track = tracks[j];
          //get stability hits
          hits = (ref = stabilityHits[track.dmType]) != null ? ref[((ref1 = track.graphs.halftime) != null ? ref1.getValue(start / track.steps) : void 0) < .5 ? 'regular' : 'halftime'] : void 0;
          if (hits) {
            hits = hits[Math.floor(((ref2 = track.graphs.stability) != null ? ref2.getValue(start / track.steps) : void 0) * (hits != null ? hits.length : void 0))];
            if (!hits) {
              continue;
            }
            if (hits.length > 4) {
              mybar = barNo % 2;
              hits = hits.slice(mybar * 4, 4);
            }
            for (i = k = 0, len1 = hits.length; k < len1; i = ++k) {
              hit = hits[i];
              if (hit) {
                track.addNote({
                  time: start + i,
                  length: .5,
                  gain: (((ref3 = track.graphs.gain) != null ? ref3.getValue(i / steps) : void 0) || 1) * ((ref4 = track.graphs.dynamics) != null ? ref4.getValue((start + i) / track.steps) : void 0)
                });
              }
            }
          }
        }
        results = [];
        for (l = 0, len2 = tracks.length; l < len2; l++) {
          track = tracks[l];
          results.push(seed = makeBar(seed, track, steps, start));
        }
        return results;
      },
      getSeq: function() {
        return seq;
      }
    };
  };

  window.DrumMachine = DrumMachine;

  module.exports = DrumMachine;

}).call(this);
