window.$ = (selector, parent) -> (parent or document).querySelector selector
window.$A = (selector, parent) -> (parent or document).querySelectorAll selector
module.exports = 'tools'