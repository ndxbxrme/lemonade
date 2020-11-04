/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = "./src/audio.coffee");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./node_modules/css-loader/dist/cjs.js!./node_modules/stylus-loader/index.js!./src/index.styl":
/*!*******************************************************************************************!*\
  !*** ./node_modules/css-loader/dist/cjs.js!./node_modules/stylus-loader!./src/index.styl ***!
  \*******************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

eval("// Imports\nvar ___CSS_LOADER_API_IMPORT___ = __webpack_require__(/*! ../node_modules/css-loader/dist/runtime/api.js */ \"./node_modules/css-loader/dist/runtime/api.js\");\nexports = ___CSS_LOADER_API_IMPORT___(false);\n// Module\nexports.push([module.i, \".alert {\\n  position: fixed;\\n  top: 1em;\\n  right: 1em;\\n  z-index: 4000;\\n  background: #000;\\n  color: #fff;\\n  padding: 1em;\\n  transition: transform 0.2s;\\n}\\n.alert.hidden {\\n  transform: translateY(-200%);\\n}\\n.alert.visible {\\n  transform: translateY(0);\\n}\\n@include '../styles/vars';\\n.modal-holder {\\n  position: fixed;\\n  width: 100%;\\n  height: 100%;\\n  min-height: 100%;\\n  z-index: 100;\\n  pointer-events: none;\\n  opacity: 0;\\n  transition: 0s 0.4s;\\n}\\n.modal-holder .modal-clickscreen {\\n  background: rgba(255,255,255,0.3);\\n  height: 100%;\\n  display: flex;\\n  justify-content: center;\\n  align-items: flex-start;\\n  opacity: 0;\\n  transition: opacity 0.2s;\\n}\\n.modal-holder .modal-clickscreen .modal-window {\\n  margin-top: 6em;\\n  background: #fff;\\n  border: 1px solid #aaa;\\n  width: 80%;\\n  max-width: 30em;\\n  max-height: 80vh;\\n  overflow-y: auto;\\n  border-radius: 1em;\\n  transition: margin 0.2s;\\n}\\nbody.modal-out .modal-holder {\\n  opacity: 1;\\n  pointer-events: all;\\n  transition: 0s;\\n}\\nbody.modal-out .modal-holder .modal-clickscreen {\\n  opacity: 1;\\n}\\nbody.modal-out .modal-holder .modal-clickscreen .modal-window {\\n  margin-top: 4em;\\n}\\nhtml,\\nbody {\\n  font-family: sans-serif;\\n}\\nhtml,\\nbody {\\n  display: flex;\\n  flex-direction: column;\\n  max-height: 100%;\\n  overflow: hidden;\\n  font-size: 0.9em;\\n  color: #eee;\\n  background: #222;\\n  height: 100%;\\n}\\ninput[type=file],\\ninput[type=file]::-webkit-file-upload-button {\\n  cursor: pointer;\\n}\\ninput {\\n  background: #111;\\n  color: #eee;\\n  border: 1px solid #000;\\n}\\ncanvas.thumbnail {\\n  border: 1px solid #000;\\n  width: 256px;\\n  height: 64px;\\n  position: absolute;\\n  top: -400em;\\n}\\ntextarea {\\n  width: 100%;\\n  height: 10em;\\n  background: #111;\\n  color: #eee;\\n}\\ntextarea,\\ninput {\\n  padding: 0.5em;\\n  box-sizing: border-box;\\n}\\nbutton {\\n  padding: 0.5em;\\n  border: 1px solid #000;\\n  border-radius: 0.3em;\\n  background: #111;\\n  box-shadow: inset 0 0 5px 0px rgba(0,0,0,0.502);\\n  cursor: pointer;\\n  color: #eee;\\n}\\nbutton:hover {\\n  background: #000;\\n}\\nbutton:active {\\n  background: #ffa500;\\n}\\n.file-add,\\n.graph-add,\\n.load-zip,\\n.merge-zip {\\n  text-align: center;\\n  position: relative;\\n  padding: 0.5em;\\n  border: 1px solid #000;\\n  border-radius: 0.3em;\\n  background: #111;\\n  color: #eee;\\n  box-shadow: inset 0 0 5px 0px rgba(0,0,0,0.502);\\n  margin-bottom: 0.5em;\\n  cursor: pointer;\\n}\\n.file-add:hover,\\n.graph-add:hover,\\n.load-zip:hover,\\n.merge-zip:hover {\\n  background: #000;\\n}\\n.file-add:active,\\n.graph-add:active,\\n.load-zip:active,\\n.merge-zip:active {\\n  background: #ffa500;\\n}\\n.file-add input[type=file],\\n.graph-add input[type=file],\\n.load-zip input[type=file],\\n.merge-zip input[type=file] {\\n  position: absolute;\\n  top: 0;\\n  left: 0;\\n  width: 100%;\\n  height: 100%;\\n  z-index: 3;\\n  opacity: 0;\\n  cursor: pointer !important;\\n}\\n.header {\\n  display: none;\\n}\\n.header h1 {\\n  text-align: center;\\n}\\n.brain {\\n  display: flex;\\n}\\n.brain .controls {\\n  margin: 0 0 1em 0;\\n}\\n.brain .brain-inner {\\n  flex: 1;\\n  display: flex;\\n  flex-direction: column;\\n}\\n.brain .brain-inner .details .item {\\n  display: flex;\\n  align-items: baseline;\\n}\\n.brain .brain-inner .details .item label {\\n  width: 7em;\\n  padding: 0.5em 0;\\n}\\n.brain .brain-inner .details .item .value input {\\n  width: 6em;\\n}\\n.project-controls {\\n  display: flex;\\n  flex-direction: column;\\n  align-items: center;\\n  padding-bottom: 1em;\\n  border-bottom: 1px solid #ccc;\\n}\\n.project-controls .control-row {\\n  display: flex;\\n}\\n.project-controls .control-row .item {\\n  display: flex;\\n  flex-direction: column;\\n}\\n.project-controls .control-row .item #seed {\\n  width: 7em;\\n}\\n.modal-holder {\\n  top: 0;\\n}\\n.modal-holder h1 {\\n  margin: 0.5em 0;\\n  text-align: center;\\n  font-size: 1.4em;\\n}\\n.modal-holder .welcome-options {\\n  display: flex;\\n  margin-bottom: 1em;\\n}\\n.modal-holder .welcome-options .option {\\n  flex: 1;\\n  position: relative;\\n  padding: 2em;\\n}\\n.modal-holder .welcome-options .option input[type=file] {\\n  position: absolute;\\n  top: 0;\\n  left: 0;\\n  width: 100%;\\n  height: 100%;\\n  opacity: 0;\\n  z-index: 3;\\n}\\n.back {\\n  display: inline-block;\\n  transform: scaleX(-1);\\n}\\n.body {\\n  display: flex;\\n  flex: 1;\\n  position: relative;\\n  overflow: hidden;\\n}\\n.body .drawer {\\n  margin-top: 1em;\\n  overflow-y: auto;\\n  flex: 1;\\n  min-width: 12em;\\n  position: relative;\\n}\\n.body .drawer .tabs {\\n  display: flex;\\n}\\n.body .drawer .tabs a {\\n  flex: 1;\\n  padding: 0.5em;\\n  cursor: pointer;\\n}\\n.body .drawer .tabs a:hover {\\n  opacity: 1;\\n}\\n.body .drawer .file-list-holder,\\n.body .drawer .graph-list-holder {\\n  flex-direction: column;\\n}\\n.body .drawer .file-list,\\n.body .drawer .graph-list {\\n  display: flex;\\n  flex-direction: column;\\n  width: 100%;\\n  max-width: 100%;\\n  font-size: 0.9em;\\n}\\n.body .drawer .file-list a,\\n.body .drawer .graph-list a {\\n  display: flex;\\n  flex-direction: column;\\n}\\n.body .drawer .file-list a label,\\n.body .drawer .graph-list a label {\\n  white-space: nobreak;\\n}\\n.body .drawer .file-list a canvas,\\n.body .drawer .graph-list a canvas {\\n  height: 2em;\\n}\\n.body .drawer .file-list a img,\\n.body .drawer .graph-list a img {\\n  width: 100%;\\n}\\n.body .page {\\n  margin-left: 1em;\\n  margin-top: 1em;\\n  width: 100%;\\n}\\n.body .editor {\\n  display: none;\\n}\\n.body .text-and-category {\\n  display: flex;\\n  position: relative;\\n  flex: 1;\\n}\\n.body .text-and-category select option {\\n  padding-right: 2em;\\n}\\n.body .graph-editor {\\n  display: flex;\\n  flex-direction: column;\\n}\\n.body .graph-editor canvas {\\n  width: 100%;\\n  height: 12em;\\n}\\n.body .graph-editor .graph-holder {\\n  overflow-x: hidden;\\n}\\n.body .graph-editor .CodeMirror {\\n  height: 100%;\\n  position: absolute;\\n  top: 0;\\n  left: 0;\\n  width: 100%;\\n}\\n.body .graph-editor h1 {\\n  margin: 0;\\n}\\n.body .graph-editor .settings {\\n  display: flex;\\n}\\n.body .graph-editor .settings .setting input {\\n  width: 100%;\\n}\\n.body .graph-editor .half {\\n  width: 60%;\\n}\\n.body .graph-editor .quarter {\\n  width: 20%;\\n}\\n.waveditor {\\n  opacity: 0;\\n  pointer-events: none;\\n}\\n.waveditor input[type=number] {\\n  width: 4em;\\n}\\n.waveditor canvas {\\n  position: absolute;\\n  top: 0;\\n  left: 0;\\n  width: 100%;\\n  height: 100%;\\n}\\n.waveditor .info {\\n  display: flex;\\n  justify-content: space-between;\\n}\\n.waveditor .info .waveform-info,\\n.waveditor .info .selection-info {\\n  display: flex;\\n}\\n.waveditor .info .waveform-info div {\\n  margin-right: 1em;\\n}\\n.waveditor .info .selection-info div {\\n  margin-left: 1em;\\n}\\n.waveform-holder,\\n.graph-holder {\\n  position: relative;\\n  height: 12em;\\n  overflow-x: scroll;\\n}\\n.waveform-holder .waveform-inner,\\n.graph-holder .waveform-inner,\\n.waveform-holder .graph-inner,\\n.graph-holder .graph-inner {\\n  position: absolute;\\n  top: 0;\\n  left: 0;\\n  width: 100%;\\n  height: 100%;\\n}\\n.waveform-holder .selection,\\n.graph-holder .selection {\\n  position: absolute;\\n  top: 0;\\n  left: 0%;\\n  width: 0%;\\n  background: #000;\\n  height: 100%;\\n  opacity: 0.4;\\n  pointer-events: none;\\n  z-index: 39;\\n}\\n.waveform-holder .cursor,\\n.graph-holder .cursor {\\n  position: absolute;\\n  top: 0;\\n  left: 0%;\\n  width: 1px;\\n  height: 100%;\\n  background: #000;\\n  pointer-events: none;\\n  z-index: 40;\\n}\\n.waveform-holder .padding,\\n.graph-holder .padding {\\n  pointer-events: none;\\n  display: inline-block;\\n}\\n.haswaveform .waveditor {\\n  opacity: 1;\\n  pointer-events: all;\\n}\\n.stategraph .graph-editor {\\n  height: 100%;\\n}\\n.stategraph .waveditor {\\n  height: 0;\\n  overflow: hidden;\\n}\\n.stategraph .brain {\\n  height: 0;\\n  overflow: hidden;\\n}\\n.statewaveform .graph-editor {\\n  height: 0;\\n  overflow: hidden;\\n}\\n.statewaveform .waveditor {\\n  height: auto;\\n}\\n.statewaveform .brain {\\n  height: 0;\\n  overflow: hidden;\\n}\\n.statebrain .graph-editor {\\n  height: 0;\\n  overflow: hidden;\\n}\\n.statebrain .waveditor {\\n  height: 0;\\n  overflow: hidden;\\n}\\n.statebrain .brain {\\n  height: auto;\\n}\\n.drawerstatefiles .graph-list-holder {\\n  height: 0;\\n  overflow: hidden;\\n}\\n.drawerstatefiles .file-list-holder {\\n  height: auto;\\n}\\n.drawerstatefiles .drawer .graphs {\\n  opacity: 0.4;\\n}\\n.drawerstategraphs .graph-list-holder {\\n  height: auto;\\n}\\n.drawerstategraphs .file-list-holder {\\n  height: 0;\\n  overflow: hidden;\\n}\\n.drawerstategraphs .files {\\n  opacity: 0.4;\\n}\\n.graph-filter,\\n.file-filter {\\n  display: none;\\n}\\n.rendered {\\n  position: relative;\\n  height: 0.3em;\\n}\\n.rendered .render-start,\\n.rendered .render-end {\\n  position: absolute;\\n  top: 0;\\n  bottom: 0;\\n  background: #00f;\\n}\\n.working .drawer,\\n.working .page,\\n.working .project-controls {\\n  opacity: 0.4;\\n  pointer-events: none;\\n}\\n.brain-stop,\\n.editor-stop,\\n.graph-stop {\\n  display: none;\\n}\\n.seq-playing .brain-play {\\n  display: none;\\n}\\n.seq-playing .brain-stop {\\n  display: inline;\\n}\\n.editor-playing .editor-play {\\n  display: none;\\n}\\n.editor-playing .editor-stop {\\n  display: inline;\\n}\\n.graph-playing .graph-play {\\n  display: none;\\n}\\n.graph-playing .graph-stop {\\n  display: inline;\\n}\\n\", \"\"]);\n// Exports\nmodule.exports = exports;\n\n\n//# sourceURL=webpack:///./src/index.styl?./node_modules/css-loader/dist/cjs.js!./node_modules/stylus-loader");

/***/ }),

/***/ "./node_modules/css-loader/dist/runtime/api.js":
/*!*****************************************************!*\
  !*** ./node_modules/css-loader/dist/runtime/api.js ***!
  \*****************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
eval("\n\n/*\n  MIT License http://www.opensource.org/licenses/mit-license.php\n  Author Tobias Koppers @sokra\n*/\n// css base code, injected by the css-loader\n// eslint-disable-next-line func-names\nmodule.exports = function (useSourceMap) {\n  var list = []; // return the list of modules as css string\n\n  list.toString = function toString() {\n    return this.map(function (item) {\n      var content = cssWithMappingToString(item, useSourceMap);\n\n      if (item[2]) {\n        return \"@media \".concat(item[2], \" {\").concat(content, \"}\");\n      }\n\n      return content;\n    }).join('');\n  }; // import a list of modules into the list\n  // eslint-disable-next-line func-names\n\n\n  list.i = function (modules, mediaQuery, dedupe) {\n    if (typeof modules === 'string') {\n      // eslint-disable-next-line no-param-reassign\n      modules = [[null, modules, '']];\n    }\n\n    var alreadyImportedModules = {};\n\n    if (dedupe) {\n      for (var i = 0; i < this.length; i++) {\n        // eslint-disable-next-line prefer-destructuring\n        var id = this[i][0];\n\n        if (id != null) {\n          alreadyImportedModules[id] = true;\n        }\n      }\n    }\n\n    for (var _i = 0; _i < modules.length; _i++) {\n      var item = [].concat(modules[_i]);\n\n      if (dedupe && alreadyImportedModules[item[0]]) {\n        // eslint-disable-next-line no-continue\n        continue;\n      }\n\n      if (mediaQuery) {\n        if (!item[2]) {\n          item[2] = mediaQuery;\n        } else {\n          item[2] = \"\".concat(mediaQuery, \" and \").concat(item[2]);\n        }\n      }\n\n      list.push(item);\n    }\n  };\n\n  return list;\n};\n\nfunction cssWithMappingToString(item, useSourceMap) {\n  var content = item[1] || ''; // eslint-disable-next-line prefer-destructuring\n\n  var cssMapping = item[3];\n\n  if (!cssMapping) {\n    return content;\n  }\n\n  if (useSourceMap && typeof btoa === 'function') {\n    var sourceMapping = toComment(cssMapping);\n    var sourceURLs = cssMapping.sources.map(function (source) {\n      return \"/*# sourceURL=\".concat(cssMapping.sourceRoot || '').concat(source, \" */\");\n    });\n    return [content].concat(sourceURLs).concat([sourceMapping]).join('\\n');\n  }\n\n  return [content].join('\\n');\n} // Adapted from convert-source-map (MIT)\n\n\nfunction toComment(sourceMap) {\n  // eslint-disable-next-line no-undef\n  var base64 = btoa(unescape(encodeURIComponent(JSON.stringify(sourceMap))));\n  var data = \"sourceMappingURL=data:application/json;charset=utf-8;base64,\".concat(base64);\n  return \"/*# \".concat(data, \" */\");\n}\n\n//# sourceURL=webpack:///./node_modules/css-loader/dist/runtime/api.js?");

/***/ }),

/***/ "./node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js":
/*!****************************************************************************!*\
  !*** ./node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js ***!
  \****************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
eval("\n\nvar isOldIE = function isOldIE() {\n  var memo;\n  return function memorize() {\n    if (typeof memo === 'undefined') {\n      // Test for IE <= 9 as proposed by Browserhacks\n      // @see http://browserhacks.com/#hack-e71d8692f65334173fee715c222cb805\n      // Tests for existence of standard globals is to allow style-loader\n      // to operate correctly into non-standard environments\n      // @see https://github.com/webpack-contrib/style-loader/issues/177\n      memo = Boolean(window && document && document.all && !window.atob);\n    }\n\n    return memo;\n  };\n}();\n\nvar getTarget = function getTarget() {\n  var memo = {};\n  return function memorize(target) {\n    if (typeof memo[target] === 'undefined') {\n      var styleTarget = document.querySelector(target); // Special case to return head of iframe instead of iframe itself\n\n      if (window.HTMLIFrameElement && styleTarget instanceof window.HTMLIFrameElement) {\n        try {\n          // This will throw an exception if access to iframe is blocked\n          // due to cross-origin restrictions\n          styleTarget = styleTarget.contentDocument.head;\n        } catch (e) {\n          // istanbul ignore next\n          styleTarget = null;\n        }\n      }\n\n      memo[target] = styleTarget;\n    }\n\n    return memo[target];\n  };\n}();\n\nvar stylesInDom = [];\n\nfunction getIndexByIdentifier(identifier) {\n  var result = -1;\n\n  for (var i = 0; i < stylesInDom.length; i++) {\n    if (stylesInDom[i].identifier === identifier) {\n      result = i;\n      break;\n    }\n  }\n\n  return result;\n}\n\nfunction modulesToDom(list, options) {\n  var idCountMap = {};\n  var identifiers = [];\n\n  for (var i = 0; i < list.length; i++) {\n    var item = list[i];\n    var id = options.base ? item[0] + options.base : item[0];\n    var count = idCountMap[id] || 0;\n    var identifier = \"\".concat(id, \" \").concat(count);\n    idCountMap[id] = count + 1;\n    var index = getIndexByIdentifier(identifier);\n    var obj = {\n      css: item[1],\n      media: item[2],\n      sourceMap: item[3]\n    };\n\n    if (index !== -1) {\n      stylesInDom[index].references++;\n      stylesInDom[index].updater(obj);\n    } else {\n      stylesInDom.push({\n        identifier: identifier,\n        updater: addStyle(obj, options),\n        references: 1\n      });\n    }\n\n    identifiers.push(identifier);\n  }\n\n  return identifiers;\n}\n\nfunction insertStyleElement(options) {\n  var style = document.createElement('style');\n  var attributes = options.attributes || {};\n\n  if (typeof attributes.nonce === 'undefined') {\n    var nonce =  true ? __webpack_require__.nc : undefined;\n\n    if (nonce) {\n      attributes.nonce = nonce;\n    }\n  }\n\n  Object.keys(attributes).forEach(function (key) {\n    style.setAttribute(key, attributes[key]);\n  });\n\n  if (typeof options.insert === 'function') {\n    options.insert(style);\n  } else {\n    var target = getTarget(options.insert || 'head');\n\n    if (!target) {\n      throw new Error(\"Couldn't find a style target. This probably means that the value for the 'insert' parameter is invalid.\");\n    }\n\n    target.appendChild(style);\n  }\n\n  return style;\n}\n\nfunction removeStyleElement(style) {\n  // istanbul ignore if\n  if (style.parentNode === null) {\n    return false;\n  }\n\n  style.parentNode.removeChild(style);\n}\n/* istanbul ignore next  */\n\n\nvar replaceText = function replaceText() {\n  var textStore = [];\n  return function replace(index, replacement) {\n    textStore[index] = replacement;\n    return textStore.filter(Boolean).join('\\n');\n  };\n}();\n\nfunction applyToSingletonTag(style, index, remove, obj) {\n  var css = remove ? '' : obj.media ? \"@media \".concat(obj.media, \" {\").concat(obj.css, \"}\") : obj.css; // For old IE\n\n  /* istanbul ignore if  */\n\n  if (style.styleSheet) {\n    style.styleSheet.cssText = replaceText(index, css);\n  } else {\n    var cssNode = document.createTextNode(css);\n    var childNodes = style.childNodes;\n\n    if (childNodes[index]) {\n      style.removeChild(childNodes[index]);\n    }\n\n    if (childNodes.length) {\n      style.insertBefore(cssNode, childNodes[index]);\n    } else {\n      style.appendChild(cssNode);\n    }\n  }\n}\n\nfunction applyToTag(style, options, obj) {\n  var css = obj.css;\n  var media = obj.media;\n  var sourceMap = obj.sourceMap;\n\n  if (media) {\n    style.setAttribute('media', media);\n  } else {\n    style.removeAttribute('media');\n  }\n\n  if (sourceMap && typeof btoa !== 'undefined') {\n    css += \"\\n/*# sourceMappingURL=data:application/json;base64,\".concat(btoa(unescape(encodeURIComponent(JSON.stringify(sourceMap)))), \" */\");\n  } // For old IE\n\n  /* istanbul ignore if  */\n\n\n  if (style.styleSheet) {\n    style.styleSheet.cssText = css;\n  } else {\n    while (style.firstChild) {\n      style.removeChild(style.firstChild);\n    }\n\n    style.appendChild(document.createTextNode(css));\n  }\n}\n\nvar singleton = null;\nvar singletonCounter = 0;\n\nfunction addStyle(obj, options) {\n  var style;\n  var update;\n  var remove;\n\n  if (options.singleton) {\n    var styleIndex = singletonCounter++;\n    style = singleton || (singleton = insertStyleElement(options));\n    update = applyToSingletonTag.bind(null, style, styleIndex, false);\n    remove = applyToSingletonTag.bind(null, style, styleIndex, true);\n  } else {\n    style = insertStyleElement(options);\n    update = applyToTag.bind(null, style, options);\n\n    remove = function remove() {\n      removeStyleElement(style);\n    };\n  }\n\n  update(obj);\n  return function updateStyle(newObj) {\n    if (newObj) {\n      if (newObj.css === obj.css && newObj.media === obj.media && newObj.sourceMap === obj.sourceMap) {\n        return;\n      }\n\n      update(obj = newObj);\n    } else {\n      remove();\n    }\n  };\n}\n\nmodule.exports = function (list, options) {\n  options = options || {}; // Force single-tag solution on IE6-9, which has a hard limit on the # of <style>\n  // tags it will allow on a page\n\n  if (!options.singleton && typeof options.singleton !== 'boolean') {\n    options.singleton = isOldIE();\n  }\n\n  list = list || [];\n  var lastIdentifiers = modulesToDom(list, options);\n  return function update(newList) {\n    newList = newList || [];\n\n    if (Object.prototype.toString.call(newList) !== '[object Array]') {\n      return;\n    }\n\n    for (var i = 0; i < lastIdentifiers.length; i++) {\n      var identifier = lastIdentifiers[i];\n      var index = getIndexByIdentifier(identifier);\n      stylesInDom[index].references--;\n    }\n\n    var newLastIdentifiers = modulesToDom(newList, options);\n\n    for (var _i = 0; _i < lastIdentifiers.length; _i++) {\n      var _identifier = lastIdentifiers[_i];\n\n      var _index = getIndexByIdentifier(_identifier);\n\n      if (stylesInDom[_index].references === 0) {\n        stylesInDom[_index].updater();\n\n        stylesInDom.splice(_index, 1);\n      }\n    }\n\n    lastIdentifiers = newLastIdentifiers;\n  };\n};\n\n//# sourceURL=webpack:///./node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js?");

/***/ }),

/***/ "./src/audio.coffee":
/*!**************************!*\
  !*** ./src/audio.coffee ***!
  \**************************/
/*! no exports provided */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
eval("__webpack_require__.r(__webpack_exports__);\n/* harmony import */ var _index_styl__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./index.styl */ \"./src/index.styl\");\n/* harmony import */ var _index_styl__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_index_styl__WEBPACK_IMPORTED_MODULE_0__);\n\n\nconsole.log('ProjectManager', ProjectManager);\n\n//ProjectManager.init()\n\n\n//# sourceURL=webpack:///./src/audio.coffee?");

/***/ }),

/***/ "./src/index.styl":
/*!************************!*\
  !*** ./src/index.styl ***!
  \************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

eval("var api = __webpack_require__(/*! ../node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js */ \"./node_modules/style-loader/dist/runtime/injectStylesIntoStyleTag.js\");\n            var content = __webpack_require__(/*! !../node_modules/css-loader/dist/cjs.js!../node_modules/stylus-loader!./index.styl */ \"./node_modules/css-loader/dist/cjs.js!./node_modules/stylus-loader/index.js!./src/index.styl\");\n\n            content = content.__esModule ? content.default : content;\n\n            if (typeof content === 'string') {\n              content = [[module.i, content, '']];\n            }\n\nvar options = {};\n\noptions.insert = \"head\";\noptions.singleton = false;\n\nvar update = api(content, options);\n\n\n\nmodule.exports = content.locals || {};\n\n//# sourceURL=webpack:///./src/index.styl?");

/***/ })

/******/ });