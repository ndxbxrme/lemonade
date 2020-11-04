// Generated by CoffeeScript 2.5.1
(function() {
  var LOG_10, Rms, dB2rap, rap2dB;

  LOG_10 = 2.302585093;

  dB2rap = function(dB) {
    return Math.exp(db * LOG_10 / 20);
  };

  rap2dB = function(rap) {
    return 20 * Math.log(rap) / LOG_10;
  };

  Rms = function(attack, attackType, swingBack, swingType, gain) {
    var currentPos, invert, linInterp, runningGain;
    runningGain = 0;
    currentPos = 0;
    invert = false;
    linInterp = function(factor, pos1, pos2) {
      return pos2 + (pos1 - pos2) * factor;
    };
    return {
      dB2rap: dB2rap,
      rap2dB: rap2dB,
      process: function(arr) {
        var i, tmp;
        runningGain = 0;
        i = 0;
        while (i < arr.length) {
          runningGain += arr[i] * arr[i] * gain;
          i++;
        }
        runningGain /= arr.length;
        tmp = Math.sqrt(runningGain);
        if (tmp > currentPos) {
          switch (attackType) {
            case 'friction':
              tmp = currentPos + ((tmp - currentPos) * attack);
              break;
            case 'increment':
              tmp = currentPos + attack;
              break;
            default:
              tmp = linInterp(attack, currentPos, tmp);
          }
        }
        if (tmp < currentPos) {
          switch (swingType) {
            case 'friction':
              tmp = currentPos + ((tmp - currentPos) * swingBack);
              break;
            case 'increment':
              tmp = currentPos - swingBack;
              break;
            default:
              tmp = linInterp(swingBack, currentPos, tmp);
          }
        }
        tmp = Math.min(1, Math.max(0, tmp));
        currentPos = tmp;
        if (invert) {
          tmp = 1 - tmp;
        }
        return tmp;
      }
    };
  };

  module.exports = Rms;

}).call(this);