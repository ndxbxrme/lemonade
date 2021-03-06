// Generated by CoffeeScript 2.5.1
(function() {
  module.exports = {
    validate: function(elem) {
      var ref, ref1, truth;
      truth = /[A-Z]/.test(elem.value) && /[a-z]/.test(elem.value) && /[^0-9^a-z]/i.test(elem.value) && elem.value.length > 7;
      if (truth) {
        elem.removeAttribute('invalid');
        return (ref = document.querySelector('.' + elem.name + '-error-validation')) != null ? ref.style.display = 'none' : void 0;
      } else {
        elem.setAttribute('invalid', true);
        return (ref1 = document.querySelector('.' + elem.name + '-error-validation')) != null ? ref1.style.display = 'block' : void 0;
      }
    }
  };

}).call(this);
