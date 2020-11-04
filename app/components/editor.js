// Generated by CoffeeScript 2.5.1
(function() {
  var Editor, modal;

  modal = require('./modal/modal.coffee');

  Editor = function(audio) {
    var clearUndoHistory, drawSelection, duration, fromViewSpace, getSelection, loopDuration, looping, mystop, parkCursor, play, playStart, playing, process, pushUndo, redo, redraw, reset, selectGraph, selection, setPlaying, source, startPos, toViewSpace, undo, undoPointer, undoStack, updateCursor, updateView, waveform, zoomFull, zoomIn, zoomOut, zoomToSelection;
    waveform = null;
    source = null;
    playing = false;
    looping = false;
    playStart = 0;
    duration = 0;
    loopDuration = 0;
    startPos = 0;
    selection = [0, 0];
    undoStack = [];
    undoPointer = -1;
    pushUndo = function() {
      while (undoStack.length && undoStack.length > undoPointer + 1) {
        undoStack.pop();
      }
      undoStack.push(waveform.extractRegion(0, waveform.getBuffer().length));
      return undoPointer++;
    };
    undo = async function() {
      var arrs;
      undoPointer--;
      if (undoPointer < 0) {
        undoPointer = 0;
      }
      arrs = undoStack[undoPointer];
      waveform = (await Waveform(audio).fromArray(arrs));
      waveform.setCanvas($('.waveditor canvas'));
      return updateView();
    };
    redo = async function() {
      var arrs;
      undoPointer++;
      if (undoPointer >= undoStack.length) {
        undoPointer = undoStack.length - 1;
      }
      if (undoPointer < 0) {
        return;
      }
      arrs = undoStack[undoPointer];
      waveform = (await Waveform(audio).fromArray(arrs));
      waveform.setCanvas($('.waveditor canvas'));
      return updateView();
    };
    reset = function() {
      setPlaying(false);
      looping = false;
      playStart = 0;
      duration = 0;
      startPos = 0;
      selection = [0, 0];
      $('.waveditor .padding').style.width = '100%';
      $('.waveditor .waveform-inner').style.left = 0;
      return $('.waveditor .waveform-holder').scrollLeft = 0;
    };
    setPlaying = function(_state) {
      playing = _state;
      if (typeof document !== "undefined" && document !== null) {
        document.body.className = document.body.className.replace(/ *editor-playing/g, '');
      }
      if (_state) {
        return typeof document !== "undefined" && document !== null ? document.body.className += ' editor-playing' : void 0;
      }
    };
    clearUndoHistory = function() {
      undoStack = [];
      return undoPointer = -1;
    };
    parkCursor = function() {
      if (!playing) {
        return $('.waveditor .cursor').style.left = toViewSpace(startPos) * 100 + '%';
      }
    };
    play = function() {
      var buffer, effectBus, effectBusScript, ref;
      if (typeof event !== "undefined" && event !== null) {
        event.target.blur();
      }
      if (effectBusScript = (ref = $('.waveditor #effectBus')) != null ? ref.value.trim() : void 0) {
        effectBus = EffectBus(audio).fromScript(effectBusScript);
        EffectBus.startGlobal();
      }
      mystop();
      playStart = audio.currentTime;
      setPlaying(true);
      //looping = true
      buffer = waveform.getBuffer();
      duration = buffer.duration;
      source = audio.createBufferSource();
      if ($('.waveditor #loop').checked) {
        looping = true;
        source.loopStart = selection[0] * duration;
        source.loopEnd = selection[0] === selection[1] ? duration : selection[1] * duration;
        loopDuration = source.loopEnd - source.loopStart;
        source.loop = true;
      }
      if (effectBus) {
        source.connect(effectBus.destination);
        effectBus.connect(audio.destination);
      } else {
        source.connect(audio.destination);
      }
      source.buffer = buffer;
      //source.loop = true
      return source.start(0, startPos * duration);
    };
    mystop = function() {
      if (typeof event !== "undefined" && event !== null) {
        event.target.blur();
      }
      if (source && playing) {
        console.trace('stopp');
        source.stop();
        //audio.close()
        //audio = new AudioContext()
        setPlaying(false);
        looping = false;
        return parkCursor();
      }
    };
    updateView = function() {
      var left, view;
      waveform.fillBins();
      if (!playing) {
        waveform.draw();
      }
      view = waveform.getView();
      $('.waveditor .padding').style.width = 1 / (view.stop - view.start) * 100 + '%';
      left = $('.waveditor .padding').offsetWidth * view.start;
      $('.waveditor .waveform-holder').scrollLeft = left;
      $('.waveform-info .duration').innerText = waveform.getBuffer().duration.toFixed(3) + 's';
      $('.waveform-info .samples').innerText = waveform.getBuffer().length.toFixed(3);
      $('.selection-info .duration').innerText = Math.abs(waveform.getBuffer().duration * (selection[1] - selection[0])).toFixed(3) + 's';
      $('.selection-info .samples').innerText = Math.abs(Math.floor(waveform.getBuffer().length * (selection[1] - selection[0])));
      $('.selection-info .hz').innerText = Math.abs(1 / (waveform.getBuffer().duration * (selection[1] - selection[0]))).toFixed(3) + 'hz';
      drawSelection();
      return parkCursor();
    };
    zoomToSelection = function() {
      var myselection;
      myselection = Array.from(selection);
      myselection.sort(function(a, b) {
        if (a > b) {
          return 1;
        } else {
          return -1;
        }
      });
      waveform.setView(myselection[0], myselection[1]);
      return updateView();
    };
    zoomIn = function(mousePos) {
      var center, diff, dur, view, wavPos;
      view = waveform.getView();
      if (typeof mousePos === 'number') {
        wavPos = ((view.stop - view.start) * mousePos) + view.start;
      }
      dur = view.stop - view.start;
      dur *= 0.9;
      view.stop = view.start + dur;
      //attempt to center startpos
      if (!playing) {
        if (wavPos) {
          view.start = wavPos - ((mousePos || .5) * dur);
          view.stop = wavPos + (1 - (mousePos || .5)) * dur;
        } else {
          center = ((view.stop - view.start) * (mousePos || .5)) + view.start;
          diff = startPos - center;
          view.start += diff;
          view.stop += diff;
        }
      }
      if (view.stop > 1) {
        view.stop = 1;
        view.start = view.stop - dur;
      }
      if (view.start < 0) {
        view.start = 0;
        view.stop = view.start + dur;
      }
      waveform.setView(view.start, view.stop);
      return updateView();
    };
    zoomOut = function(mousePos) {
      var center, diff, dur, view, wavPos;
      view = waveform.getView();
      if (typeof mousePos === 'number') {
        wavPos = ((view.stop - view.start) * mousePos) + view.start;
      }
      dur = view.stop - view.start;
      dur *= 1.1;
      view.stop = view.start + dur;
      if (!playing) {
        if (wavPos) {
          view.start = wavPos - ((mousePos || .5) * dur);
          view.stop = wavPos + (1 - (mousePos || .5)) * dur;
        } else {
          center = ((view.stop - view.start) * (mousePos || .5)) + view.start;
          diff = startPos - center;
          view.start += diff;
          view.stop += diff;
        }
      }
      if (view.stop > 1) {
        view.stop = 1;
        view.start = Math.max(0, view.stop - dur);
      }
      if (view.start < 0) {
        view.start = 0;
        view.stop = Math.min(1, view.start + dur);
      }
      waveform.setView(view.start, view.stop);
      return updateView();
    };
    zoomFull = function() {
      waveform.setView(0, 1);
      return updateView();
    };
    redraw = function() {
      waveform.setCanvas($('.waveditor canvas'));
      waveform.fillBins();
      return waveform.draw();
    };
    toViewSpace = function(x) {
      var view;
      view = waveform.getView();
      return (x - view.start) / (view.stop - view.start);
    };
    fromViewSpace = function(x) {
      var view;
      view = waveform.getView();
      return x * (view.stop - view.start) + view.start;
    };
    drawSelection = function() {
      var myselection, sElm;
      myselection = Array.from(selection);
      myselection = myselection.sort(function(a, b) {
        if (a > b) {
          return 1;
        } else {
          return -1;
        }
      });
      sElm = $('.waveditor .selection');
      startPos = myselection[0];
      parkCursor();
      sElm.style.left = toViewSpace(myselection[0]) * 100 + '%';
      sElm.style.width = (toViewSpace(myselection[1]) - toViewSpace(myselection[0])) * 100 + '%';
      $('.selection-info .duration').innerText = (waveform.getBuffer().duration * (selection[1] - selection[0])).toFixed(3) + 's';
      $('.selection-info .samples').innerText = Math.floor(waveform.getBuffer().length * (selection[1] - selection[0]));
      return $('.selection-info .hz').innerText = (1 / (waveform.getBuffer().duration * (selection[1] - selection[0]))).toFixed(3) + 'hz';
    };
    updateCursor = function() {
      var currentPos, left, myselection, scrollAmount;
      if (playing) {
        currentPos = (audio.currentTime - playStart + startPos * duration) / duration;
        if (looping) {
          if (selection && selection.length && selection[0] !== selection[1]) {
            myselection = Array.from(selection);
          } else {
            myselection = [toViewSpace(0), toViewSpace(1)];
          }
          myselection.sort(function(a, b) {
            if (a > b) {
              return 1;
            } else {
              return -1;
            }
          });
          if (currentPos > myselection[1]) {
            currentPos = myselection[0] + (currentPos - myselection[0]) % (myselection[1] - myselection[0]);
          }
        } else {
          if (currentPos > 1) {
            currentPos = startPos;
            $('.waveditor .waveform-holder').scrollLeft = startPos * $('.waveditor .waveform-inner').offsetWidth;
            setPlaying(false);
          }
        }
        left = toViewSpace(currentPos);
        if (left < 0) {
          scrollAmount = left * $('.waveditor .waveform-inner').offsetWidth;
          $('.waveditor .waveform-holder').scrollLeft += scrollAmount;
          left = 0;
        } else if (left > 0.5) {
          //scroll if necessary
          scrollAmount = (left - 0.5) * $('.waveditor .waveform-inner').offsetWidth;
          $('.waveditor .waveform-holder').scrollLeft += scrollAmount;
        }
        //left = 0.5
        $('.waveditor .cursor').style.left = left * 100 + '%';
      }
      return window.requestAnimationFrame(updateCursor);
    };
    updateCursor();
    getSelection = function(ignoreSameCheck) {
      var length, mysel;
      if ((selection && selection.length && selection[0] !== selection[1]) || ignoreSameCheck) {
        mysel = Array.from(selection);
      } else {
        mysel = [0, 1];
      }
      mysel.sort(function(a, b) {
        if (a > b) {
          return 1;
        } else {
          return -1;
        }
      });
      length = waveform.getBuffer().length;
      return [Math.floor(mysel[0] * length), Math.floor(mysel[1] * length)];
    };
    process = async function(c, cb) {
      var arrs, channel, data, i, index, mix, mysel, name, view, weld, weldEnd, weldLength, weldStart;
      view = waveform.getView();
      c = c || 3;
      mysel = getSelection();
      arrs = waveform.extractRegion(0, waveform.getBuffer().length);
      weldLength = 100;
      weldStart = waveform.extractRegion(mysel[0], mysel[0] + weldLength);
      weldEnd = waveform.extractRegion(mysel[1] - weldLength, mysel[1]);
      channel = 0;
      while (channel < waveform.getBuffer().numberOfChannels) {
        if (c & (channel + 1)) {
          index = mysel[0];
          while (index < mysel[1]) {
            cb(arrs, channel, index, mysel[0], mysel[1]);
            index++;
          }
        }
        channel++;
      }
      if (mysel[0] > 0) {
        //weld Start
        channel = 0;
        while (channel < waveform.getBuffer().numberOfChannels) {
          if (c & (channel + 1)) {
            i = 0;
            while (i < weldStart[channel].length) {
              mix = i / weldStart[channel].length;
              data = arrs[channel][mysel[0] + i];
              weld = weldStart[channel][i];
              arrs[channel][mysel[0] + i] = (data * mix) + (weld * (1 - mix));
              i++;
            }
          }
          channel++;
        }
      }
      if (mysel[1] < waveform.getBuffer().length) {
        //weld End
        channel = 0;
        while (channel < waveform.getBuffer().numberOfChannels) {
          if (c & (channel + 1)) {
            i = 0;
            while (i < weldEnd[channel].length) {
              mix = i / weldEnd[channel].length;
              data = arrs[channel][(mysel[1] - weldLength) + i];
              weld = weldEnd[channel][i];
              arrs[channel][(mysel[1] - weldLength) + i] = (weld * mix) + (data * (1 - mix));
              i++;
            }
          }
          channel++;
        }
      }
      name = waveform.name;
      waveform = (await Waveform(audio).fromArray(arrs));
      waveform.setCanvas($('.waveditor canvas'));
      waveform.setView(view.start, view.stop);
      waveform.name = name;
      pushUndo();
      return updateView();
    };
    selectGraph = async function(graph) {
      var e, modalHtml;
      if (!graph) {
        modalHtml = pug.render($('#modal-graph-select').innerText.replace(/\n  /g, '\n'), {
          graphs: Object.keys(ProjectManager.getGraphs())
        });
        try {
          await modal.show(modalHtml, function(resolve, reject) {
            ProjectManager.submit = function() {
              var selectedGraph;
              selectedGraph = $('.modal-content .graph-select').value;
              graph = ProjectManager.getGraphs()[selectedGraph];
              return resolve();
            };
            return ProjectManager.cancel = function() {
              return reject();
            };
          });
          modal.hide();
        } catch (error) {
          e = error;
          return;
        }
      }
      return graph;
    };
    return {
      init: function() {
        return window.addEventListener('keydown', function(event) {
          if (event.code === 'Space') {
            if (playing) {
              return mystop();
            } else {
              return play();
            }
          } else if (event.code === 'KeyZ') {
            return zoomToSelection();
          }
        });
      },
      cursorToStart: function() {
        var currentPos;
        currentPos = 0;
        startPos = 0;
        if (!playing) {
          return parkCursor();
        } else {
          mystop();
          return play();
        }
      },
      cursorToEnd: function() {
        var currentPos;
        currentPos = 1;
        startPos = 1;
        if (!playing) {
          return parkCursor();
        } else {
          mystop();
          return play();
        }
      },
      renderGraphClick: async function() {
        var modalHtml, result;
        audio = audio || new AudioContext();
        modalHtml = app.pug.render($('script#modal-render-graph').innerText.replace(/\n  /g, '\n'));
        try {
          result = (await app.modal.show(modalHtml, function(resolve, reject) {
            editor.submit = async function() {
              return resolve((await app.formValidator.validate('.modal-holder form')));
            };
            return editor.cancel = reject;
          }));
        } catch (error) {}
        await app.modal.hide();
        if (result) {
          return this.renderGraph(result.b64, result.length);
        }
      },
      renderGraph: async function(b64, length) {
        var arr, currentPos, currentVal, fn, graph, i, nosmps, oswaveform, oversample, oversampled;
        audio = audio || new AudioContext();
        mystop();
        oversample = 8;
        graph = (await Graph.fromBase64(b64));
        fn = graph.fn();
        nosmps = +length * audio.sampleRate * oversample;
        oversampled = new Float32Array(nosmps);
        i = 0;
        while (i < nosmps) {
          oversampled[i] = (await graph.getValue(i / nosmps));
          i++;
        }
        oswaveform = (await Waveform(audio).fromArray([oversampled]));
        await oswaveform.renderEffect(function(ctx) {
          var filter;
          filter = ctx.createBiquadFilter();
          filter.type = 'lowpass';
          filter.frequency = ctx.sampleRate / oversample;
          return filter;
        }, null, 0.1);
        [oversampled] = oswaveform.extractRegion(0, oswaveform.getBuffer().length);
        i = 0;
        arr = new Float32Array(+length * audio.sampleRate);
        currentVal = 0;
        currentPos = 0;
        while (i < nosmps) {
          if (Math.floor(i / oversample) !== currentPos) {
            arr[currentPos] = currentVal / oversample;
            currentPos++;
            currentVal = 0;
          }
          currentVal += oversampled[i];
          i++;
        }
        arr[currentPos] = currentVal / oversample;
        waveform = (await Waveform(audio).fromArray([arr]));
        reset();
        waveform.setCanvas($('.waveditor canvas'));
        return updateView();
      },
      mouseDown: function() {
        var mypos, pos;
        event.preventDefault();
        if (event.buttons === 1) {
          pos = event.layerX / event.target.offsetWidth;
          if (event.shiftKey) {
            mypos = fromViewSpace(pos);
            selection[0] = selection[0] || 0;
            selection[1] = selection[1] || 0;
            if (mypos < selection[0]) {
              selection[0] = mypos;
            }
            if (mypos > selection[0]) {
              selection[1] = mypos;
            }
          } else {
            selection[0] = fromViewSpace(pos);
            selection[1] = fromViewSpace(pos);
          }
          startPos = selection[0];
          drawSelection();
          if (!playing) {
            return parkCursor();
          } else {
            mystop();
            //set loop position
            return play();
          }
        }
      },
      mouseUp: function() {},
      mouseMove: function() {
        var pos;
        if (event.buttons === 1) {
          pos = event.layerX / event.target.offsetWidth;
          selection[1] = fromViewSpace(pos);
          return drawSelection();
        }
      },
      //scroll if close to edge
      mouseOut: function() {
        var view;
        //did we leave the right side?
        view = waveform.getView();
        if (event.offsetX >= event.target.clientWidth) {
          selection[1] = view.stop;
          return drawSelection();
        } else if (event.offsetX <= 0) {
          selection[0] = view.start;
          return drawSelection();
        }
      },
      //if so set selection[1] to view.stop
      click: function() {},
      //startPos = event.layerX / event.target.offsetWidth *  100
      //parkCursor()
      //play()
      mouseWheel: function() {
        var pos;
        pos = event.layerX / event.target.offsetWidth;
        if (Math.abs(event.deltaY)) {
          if (Math.sign(event.deltaY) < 0) {
            zoomIn(pos);
          } else {
            zoomOut(pos);
          }
        }
        return event.preventDefault();
      },
      scroll: function() {
        var diff, view, viewStart, viewStop;
        $('.waveditor .waveform-inner').style.left = event.target.scrollLeft + 'px';
        viewStart = event.target.scrollLeft / $('.waveditor .padding').offsetWidth;
        view = waveform.getView();
        diff = viewStart - view.start;
        viewStop = view.stop + diff;
        waveform.setView(viewStart, viewStop);
        redraw();
        drawSelection();
        if (!playing) {
          return parkCursor();
        }
      },
      selectFile: async function(fileElm) {
        if (!fileElm || !fileElm.files) {
          return;
        }
        reset();
        clearUndoHistory();
        audio = audio || new AudioContext();
        waveform = (await Waveform(audio).fromFile(fileElm.files[0]));
        waveform.setCanvas($('.waveditor canvas'));
        pushUndo();
        return updateView();
      },
      saveFile: function() {
        return FileSaver.saveAs(waveform.toWave(), $('.waveditor .name').value + '.wav');
      },
      selectWaveform: function(name, _waveform, tags) {
        reset();
        clearUndoHistory();
        $('.waveditor .name').value = name;
        waveform = _waveform;
        waveform.name = name;
        waveform.setCanvas($('.waveditor canvas'));
        document.querySelectorAll('.waveditor .tags option').forEach(function(item) {
          item.selected = false;
          if (tags && tags.includes(item.innerText)) {
            return item.selected = true;
          }
        });
        pushUndo();
        return updateView();
      },
      play: play,
      stop: mystop,
      zoomToSelection: zoomToSelection,
      zoomIn: zoomIn,
      zoomOut: zoomOut,
      zoomFull: zoomFull,
      normalize: async function() {
        await waveform.normalize();
        pushUndo();
        return redraw();
      },
      topDeck: async function() {
        await waveform.topDeck();
        pushUndo();
        return redraw();
      },
      onlyTops: async function() {
        await waveform.onlyTops();
        pushUndo();
        waveform.fillBins();
        return waveform.draw();
      },
      extractSelection: async function() {
        var arrs, c, i, k, l, len, len1, length, ref, start, stop, xfade, xfadearrs, xfadechannel, xfadesample;
        if (selection[0] !== selection[1]) {
          selection.sort(function(a, b) {
            if (a > b) {
              return 1;
            } else {
              return -1;
            }
          });
          length = waveform.getBuffer().length;
          start = Math.floor(fromViewSpace(selection[0]) * length);
          stop = Math.floor(fromViewSpace(selection[1]) * length);
          arrs = waveform.extractRegion(start, stop);
          if (xfade = (ref = $('.waveditor .xfade')) != null ? ref.value : void 0) {
            stop++;
            xfadearrs = waveform.extractRegion(stop, stop + +xfade);
            for (c = k = 0, len = xfadearrs.length; k < len; c = ++k) {
              xfadechannel = xfadearrs[c];
              for (i = l = 0, len1 = xfadechannel.length; l < len1; i = ++l) {
                xfadesample = xfadechannel[i];
                arrs[c][i] = arrs[c][i] * (i / xfadechannel.length) + xfadesample * (1 - i / xfadechannel.length);
              }
            }
          }
          //undo
          reset();
          waveform = (await Waveform(audio).fromArray(arrs));
          waveform.setCanvas($('.waveditor canvas'));
          pushUndo();
          return updateView();
        }
      },
      deleteSelection: async function() {
        var arrs, c, endArrs, index, j, length, outArr, start, startArrs, stop;
        if (selection[0] !== selection[1]) {
          selection.sort(function(a, b) {
            if (a > b) {
              return 1;
            } else {
              return -1;
            }
          });
          length = waveform.getBuffer().length;
          start = Math.floor(fromViewSpace(selection[0]) * length);
          stop = Math.floor(fromViewSpace(selection[1]) * length);
          startArrs = waveform.extractRegion(0, start);
          endArrs = waveform.extractRegion(stop, length);
          arrs = new Array(waveform.getBuffer().numberOfChannels);
          c = 0;
          while (c < arrs.length) {
            outArr = new Float32Array(startArrs[c].length + endArrs[c].length);
            index = 0;
            j = 0;
            while (j < startArrs[c].length) {
              outArr[index++] = startArrs[c][j];
              j++;
            }
            j = 0;
            while (j < endArrs[c].length) {
              outArr[index++] = endArrs[c][j];
              j++;
            }
            arrs[c] = outArr;
            c++;
          }
          reset();
          waveform = (await Waveform(audio).fromArray(arrs));
          waveform.setCanvas($('.waveditor canvas'));
          pushUndo();
          return updateView();
        }
      },
      extractChannel: async function(c) {
        var arrs, tmparrs;
        tmparrs = waveform.extractRegion(0, waveform.getBuffer().length);
        arrs = [];
        arrs.push(tmparrs[Math.min(c, waveform.getBuffer().numberOfChannels - 1)]);
        reset();
        waveform = (await Waveform(audio).fromArray(arrs));
        waveform.setCanvas($('.waveditor canvas'));
        pushUndo();
        return updateView();
      },
      setLoopStart: async function() {
        var arrs, c, endArrs, mysel, startArrs;
        arrs = [];
        mysel = getSelection(true);
        startArrs = waveform.extractRegion(0, mysel[0]);
        endArrs = waveform.extractRegion(mysel[0], waveform.getBuffer().length);
        c = 0;
        while (c < startArrs.length) {
          arrs.push(Float32Array.from([...endArrs[c], ...startArrs[c]]));
          c++;
        }
        waveform = (await Waveform(audio).fromArray(arrs));
        waveform.setCanvas($('.waveditor canvas'));
        pushUndo();
        return updateView();
      },
      resize: async function() {
        var factor;
        factor = +$('.resize-factor').value;
        await waveform.resize(factor);
        pushUndo();
        return updateView();
      },
      mute: function(c) {
        return process(c, function(arrs, c, index, start, stop) {
          return arrs[c][index] = 0;
        });
      },
      fadeIn: function(c) {
        return process(c, function(arrs, c, index, start, stop) {
          return arrs[c][index] = arrs[c][index] * ((index - start) / (stop - start));
        });
      },
      fadeOut: function(c) {
        return process(c, function(arrs, c, index, start, stop) {
          return arrs[c][index] = arrs[c][index] * (1 - ((index - start) / (stop - start)));
        });
      },
      declack: function(c) {
        var fade;
        fade = 5;
        return process(c, function(arrs, c, index, start, stop) {
          return arrs[c][index] = arrs[c][index] * Math.min(index / fade, Math.min(1 - ((x - (stop - fade)) / fade), 1));
        });
      },
      smooth: function(c) {
        var factor;
        factor = 0.1;
        return process(c, function(arrs, c, index, start, stop) {
          var curr, dist, last;
          last = arrs[c][index - 1] || 0;
          curr = arrs[c][index];
          dist = curr - last;
          if (Math.abs(dist > factor)) {
            return arrs[c][index] = last + Math.sign(dist) * factor;
          }
        });
      },
      reverse: function(c) {
        return process(c, function(arrs, c, index, start, stop) {
          var halfway, tmp1, tmp2;
          halfway = start + (stop - start) * .5;
          if (index < halfway) {
            tmp1 = arrs[c][index];
            tmp2 = arrs[c][(stop - (index - start)) - 1];
            arrs[c][index] = tmp2;
            return arrs[c][(stop - (index - start)) - 1] = tmp1;
          }
        });
      },
      gainFromGraph: async function(c, graph) {
        graph = (await selectGraph(graph));
        if (!graph) {
          return;
        }
        return process(c, function(arrs, c, index, start, stop) {
          return arrs[c][index] = arrs[c][index] * graph.getValue((index - start) / (stop - start));
        });
      },
      waveshapeFromGraph: async function(c, graph) {
        graph = (await selectGraph(graph));
        if (!graph) {
          return;
        }
        return process(c, function(arrs, c, index, start, stop) {
          return arrs[c][index] = graph.getValue(arrs[c][index]);
        });
      },
      swapChannels: function() {
        return process(c, function(arrs, c, index, start, stop) {
          var tmp1, tmp2;
          if (c === 0) {
            tmp1 = arrs[0][index];
            tmp2 = arrs[1][index];
            arrs[0][index] = tmp2;
            return arrs[1][index] = tmp1;
          }
        });
      },
      renderScript: async function() {
        var instructions, ref, scriptText, seed;
        if (typeof ProjectManager !== "undefined" && ProjectManager !== null) {
          ProjectManager.setWorking();
        }
        seed = (typeof ProjectManager !== "undefined" && ProjectManager !== null ? (ref = ProjectManager.getProject()) != null ? ref.seed : void 0 : void 0) || 200;
        scriptText = $('.waveditor .script').value.trim();
        scriptText = scriptText.replace(/\n[ +]/g, '');
        instructions = scriptText.split('\n');
        await waveform.renderScript(instructions, seed, waveform.name);
        waveform.setCanvas($('.waveditor canvas'));
        pushUndo();
        updateView();
        return typeof ProjectManager !== "undefined" && ProjectManager !== null ? ProjectManager.clearWorking() : void 0;
      },
      getWaveform: function() {
        return waveform;
      },
      setAudio: function(_audio) {
        return audio = _audio;
      },
      saveWaveform: function() {
        return ProjectManager.saveWaveform($('.waveditor .name').value, waveform, Array.from(document.querySelectorAll('.waveditor .tags option')).reduce(function(result, item) {
          if (item.selected) {
            result.push(item.innerText);
          }
          return result;
        }, []));
      },
      undo: undo,
      redo: redo,
      currentWaveform: function() {
        return waveform;
      },
      hasWaveform: function() {
        return waveform !== null;
      },
      clearWaveform: function() {
        return waveform = null;
      },
      waveformName: function() {
        return waveform != null ? waveform.name : void 0;
      }
    };
  };

  window.Editor = Editor;

  module.exports = Editor;

}).call(this);
