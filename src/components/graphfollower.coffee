GraphFollower = (audio) ->
  graph = null
  constantNode = null
  duration = null
  multiplier = 1
  offset = 0
  startTime = 0
  lastTime = 0
  fromGraph: (_graph, _duration, _multiplier, _offset, time) -> 
    graph = _graph
    duration = _duration
    multiplier = multiplier or _multiplier
    offset = offset or _offset or 0
    constantNode = audio.createConstantSource()
    constantNode.offset.value = offset
    constantNode.start()
    startTime = time or audio.currentTime
    lastTime = startTime
    connect: (what) ->
      constantNode.connect what
    start: (time) ->
      startTime = time or audio.currentTime
      lastTime = startTime
    update: ->
      nextTime = audio.currentTime - lastTime
      nextTime = Math.max nextTime, (1 / 120)
      lastTime = audio.currentTime
      x = ((audio.currentTime - startTime) % duration) / duration
      val = graph.getValue x
      constantNode.offset.setTargetAtTime (val * multiplier) + offset, audio.currentTime + nextTime, 0.5
      
window.GraphFollower = GraphFollower
module.exports = GraphFollower