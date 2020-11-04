module.exports =
  validate: (elem) ->
    truth = /[A-Z]/.test(elem.value) and /[a-z]/.test(elem.value) and /[^0-9^a-z]/i.test(elem.value) and elem.value.length > 7
    if truth
      elem.removeAttribute 'invalid'
      document.querySelector('.' + elem.name + '-error-validation')?.style.display = 'none'
    else
      elem.setAttribute 'invalid', true
      document.querySelector('.' + elem.name + '-error-validation')?.style.display = 'block'