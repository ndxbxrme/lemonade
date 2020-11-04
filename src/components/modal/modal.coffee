holder = document.createElement 'div'
holder.className = 'modal-holder'
holder.innerHTML += require('./modal.pug')()
document.body.appendChild holder
module.exports =
  setContent: (content) ->
  show: (content, controller) ->
    new Promise (resolve, reject) ->
      modalWindow = document.querySelector '.modal-window'
      modalWindow.innerHTML = content
      controller? resolve, reject
      document.body.className = document.body.className.replace(/ *modal-out/, '') + ' modal-out'
  hide: ->
    document.body.className = document.body.className.replace(/ *modal-out/, '')
    modalWindow = document.querySelector '.modal-window'
    setTimeout ->
      modalWindow.innerHTML = ''
    , 400