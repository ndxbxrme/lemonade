// Generated by CoffeeScript 2.5.1
(function() {
  window.LFO = function(opts) {
    var osc, oscGain;
    osc = opts.audio.createOscillator();
    osc.frequency.value = opts.frequency || 1;
    oscGain = opts.audio.createGain();
    oscGain.gain.value = opts.value || 10;
    osc.connect(oscGain);
    return {
      connect: function(thing) {
        return oscGain.connect(thing);
      },
      osc: osc,
      gain: oscGain,
      start: function() {
        return osc.start();
      },
      stop: function() {
        return osc.stop();
      }
    };
  };

  module.exports = window.LFO;

}).call(this);
