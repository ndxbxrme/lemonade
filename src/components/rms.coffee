LOG_10 = 2.302585093
dB2rap = (dB) ->
  Math.exp(db * LOG_10 / 20)
rap2dB = (rap) ->
  20 * Math.log(rap) / LOG_10
Rms = (attack, attackType, swingBack, swingType, gain) ->
  runningGain = 0
  currentPos = 0
  invert = false
  linInterp = (factor, pos1, pos2) ->
    pos2 + (pos1 - pos2) * factor
  dB2rap: dB2rap
  rap2dB: rap2dB
  process: (arr) ->
    runningGain = 0
    i = 0
    while i < arr.length
      runningGain += arr[i] * arr[i] * gain
      i++
    runningGain /= arr.length
    tmp = Math.sqrt runningGain
    if tmp > currentPos
      switch attackType
        when 'friction'
          tmp = currentPos + ((tmp - currentPos) * attack)
        when 'increment'
          tmp = currentPos + attack
        else
          tmp = linInterp attack, currentPos, tmp
    if tmp < currentPos
      switch swingType
        when 'friction'
          tmp = currentPos + ((tmp - currentPos) * swingBack)
        when 'increment'
          tmp = currentPos - swingBack
        else
          tmp = linInterp swingBack, currentPos, tmp
    tmp = Math.min 1, Math.max 0, tmp
    currentPos = tmp
    tmp = 1 - tmp if invert
    tmp
module.exports = Rms