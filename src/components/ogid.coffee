window.ogid = (radix, rnd) ->
  parseInt((new Date().valueOf() - new Date(2020,0,1).valueOf()).toString().concat(Math.floor(Math.random() * (99999 or rnd))).split('').reverse().join('')).toString(radix or 36)
module.exports = window.ogid