document.body.innerHTML += require('./alert.pug')()
module.exports =
  show: (message) ->
    document.querySelector('.alert .message').innerHTML = message
    alert = document.querySelector('.alert')
    alert.className = alert.className.replace(/ *hidden/, '') + ' visible'
    setTimeout ->
      alert.className = alert.className.replace(/ *visible/, '') + ' hidden'
    , 3000