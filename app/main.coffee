this.Conway ?= {}

_.extend Conway,
  geometry:
    width: 20
    height: 20

class Conway.Cell
  constructor: (@document) ->
  cssClassList: ->
    {state: state} = @document
    "state-#{state}"      
  neighbors: (selector = {}) ->
    {x: x, y: y} = @document
    _(Conway.cellCollection).select (doc) ->
      {x: nx, y: ny, state: state} = doc

      isMe = x is nx and y is ny
      dx = Math.abs(x - nx)
      dy = Math.abs(y - ny)
 
      isNeighbor = 
        (dx <= 1 or dx is 20 - 1) and
        (dy <= 1 or dy is 20 - 1) and
        not isMe

      isNeighbor and state is 'on'
  inverseState: ->
    if @document.state is 'on'
      'off'
    else
      'on'
  clone: ->
    new Conway.Cell @document
  update: (documentFragment) ->
    Conway.cellCollectionDependency.changed()
    _(@document).extend documentFragment

