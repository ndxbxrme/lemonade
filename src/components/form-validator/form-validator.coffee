validators =
  required: (elem) ->
    elem.value
  invalid: (elem) ->
    false
  confirm: (elem) ->
    elem.value is document.querySelector('.next input[name=' + elem.name.replace('Confirm', '') + ']').value
  password: (elem) ->
    /[A-Z]/.test(elem.value) and /[a-z]/.test(elem.value) and /[^0-9^a-z]/i.test(elem.value) and elem.value.length > 7
  email: (elem) ->
    /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/i.test(elem.value)
module.exports =
  validate: (eventSelector, shouldThrow) ->
    formSelector = '.next form'
    formSelector = eventSelector if typeof(eventSelector) is 'string'
    form = document.querySelector formSelector
    output = {}
    truth = true
    errors = []
    for elem in form.elements
      if elem.name
        output[elem.name] = elem.value
        output[elem.name] = +output[elem.name] if elem.type is 'number'
        localTruth = true
        for name in elem.getAttributeNames()
          if validators[name]
            elem.className = elem.className.replace(/ *invalid| *valid/g, '')
            validatorTruth = validators[name](elem)
            localTruth = localTruth and validatorTruth
            if not validatorTruth
              errors.push 
                name: elem.name + '-' + name 
                dirty: elem.dirty
              elem.className += ' invalid' if elem.dirty
            else
              elem.className += ' valid' if elem.dirty
            continue if not localTruth
        truth = truth and localTruth
    form.querySelectorAll('.error').forEach (elem) ->
      elem.className = elem.className.replace(/ *invalid/g, '')
    if truth
      form.className = form.className.replace(/ *invalid/g, '')
    else
      form.className = form.className.replace(/ *invalid/g, '') + ' invalid'
      for error in errors
        elem = document.querySelector '.error.' + error.name
        elem.className += ' invalid' if elem and (shouldThrow or error.dirty)
      if shouldThrow
        throw 'invalid'
    output
  init: (selector) ->
    form = document.querySelector selector or 'form'
    for elem in form.elements
      if elem.name
        elem.onchange = (ev) =>
          ev.srcElement.dirty = true
          @.validate()
        elem.onkeyup = @.validate
    @.validate()