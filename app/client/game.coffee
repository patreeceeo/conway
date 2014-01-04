debounce = (delay, fn) ->
  _.throttle fn, delay

_.extend Template.game, do ->
  dragging = false
  showPlayButton: ->
    not Session.get 'automaton:isRunning'
  showPauseButton: ->
    Session.get 'automaton:isRunning'
  tiles: ->
    GameTileCollection.find()
  events: 
    'mousedown .tile': (event) ->
      event.preventDefault()
      tile = GameTileCollection.findOne $(event.target).data('tileId')
      tile.update state: tile.inverseState()
      dragging = true
    'mouseup .tile': (event) ->
      dragging = false
    'mouseleave .matrix': (event) ->
      dragging = false
    'mouseleave .tile': (event) ->
      if dragging
        tile = GameTileCollection.findOne $(event.target).data('tileId')
        tile.update state: tile.inverseState()
    'dragstart .tile': (event) ->
      event.preventDefault()
      false
    'click [data-button=pause]': ->
      Session.set 'automaton:isRunning', false
    'click [data-button=play]': ->
      Session.set 'automaton:isRunning', true



      




