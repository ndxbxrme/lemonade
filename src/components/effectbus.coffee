globalDefs = {}
EffectBus = (audio) ->
  effects = []
  fromScript: (script) ->
    script = script.trim().replace /\n[ +]/g, ''
    instructions = script.split '\n'
    for instruction, i in instructions
      [all, name, args] = instruction.match /(.*?)\((.*?)\)/
      defName = null
      if /def /.test name
        [all, defName, name] = name.match /def (.*?) (.*)/
      args = JSON.parse args
      effect = audio['create' + name]()
      for key, val of args
        if typeof(val) is 'string'
          if /@/.test val
            #connect to global
            [all, globalName, mult, offset] = val.match /(.*?)@([^\+]+)[\+$]*(.*)/
            multGain = audio.createGain()
            multGain.gain.value = +(mult or '1.0')
            offsetGain = audio.createGain()
            offsetGain.gain.value = +(offset or '0.0')
            globalDefs[globalName].connect multGain
            multGain.connect offsetGain
            offsetGain.connect effect[key]
          else
            effect[key] = val
        else
          effect[key].value = val
      if defName
        globalDefs[defName] = effect
      else
        effects[effects.length - 1].connect effect if effects.length > 0
        effects.push effect
    connect: (thing) ->
      effects[effects.length - 1].connect thing
    destination: effects[0]
EffectBus.startGlobal = (time) ->
  for key, effect of globalDefs
    effect.start?(time)
window.EffectBus = EffectBus
module.exports = EffectBus