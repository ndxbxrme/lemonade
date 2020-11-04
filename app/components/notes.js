// Generated by CoffeeScript 2.5.1
(function() {
  var MAX_OFFSET, makeFreqs, noteNames, notesByMIDINo, notesByName;

  MAX_OFFSET = 7 * 12;

  noteNames = ['a', 'a#', 'b', 'c', 'c#', 'd', 'd#', 'e', 'f', 'f#', 'g', 'g#'];

  notesByName = {};

  notesByMIDINo = [];

  makeFreqs = function() {
    var a, freq, nnOffset, noteName, octave, offset, results;
    offset = -4 * 12;
    a = Math.pow(2, 1 / 12);
    results = [];
    while (offset < MAX_OFFSET) {
      nnOffset = offset;
      while (nnOffset < 0) {
        nnOffset += 12;
      }
      noteName = noteNames[nnOffset % 12];
      octave = Math.floor((offset - 3) / 12) + 4;
      if (octave > -1) {
        freq = 440 * 10000000000 * Math.pow(a, offset);
        freq = +(Math.round(freq) * 0.0000000001).toFixed(10);
        notesByName[noteName + octave] = freq;
        notesByMIDINo.push({
          name: noteName,
          freq: freq
        });
      }
      results.push(offset++);
    }
    return results;
  };

  makeFreqs();

  module.exports = {
    byName: notesByName,
    byMIDINo: notesByMIDINo
  };

}).call(this);
