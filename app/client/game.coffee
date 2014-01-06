debounce = (delay, fn) ->
  _.throttle fn, delay

_.extend Template.game, do ->
  dragging = false
  showPlayButton: ->
    not Session.get 'automaton:isRunning'
  showPauseButton: ->
    Session.get 'automaton:isRunning'
  cells: ->
    Conway.cellCollection.find()
  events: 
    'mousedown [data-cell-ID]': (event) ->
      event.preventDefault()
      cell = Conway.cellCollection.findOne $(event.target).data('cellId')
      cell.update state: cell.inverseState()
      dragging = true
    'mouseup [data-cell-ID]': (event) ->
      dragging = false
    'mouseleave .matrix': (event) ->
      dragging = false
    'mouseleave [data-cell-ID]': (event) ->
      if dragging
        cell = Conway.cellCollection.findOne $(event.target).data('cellId')
        cell.update state: cell.inverseState()
    'dragstart [data-cell-ID]': (event) ->
      event.preventDefault()
      false
    'click [data-button=pause]': ->
      Session.set 'automaton:isRunning', false
    'click [data-button=play]': ->
      Session.set 'automaton:isRunning', true



      




