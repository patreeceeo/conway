class ConwayCell
  constructor: (@document) ->
  cssClassList: ->
    {state: state} = @document
    "state-#{state}"      
  neighbors: (selector = {}) ->
    {x: x, y: y} = @document
    wrap = (v, min = 1, max = 20) ->
      Math.max(min, Math.min(v, max))
    lx = wrap x - 1
    rx = wrap x + 1
    uy = wrap y - 1
    dy = wrap y + 1

    Conway.cellCollection.find _.extend selector,
      $or: [
        {
          x: $in: [lx, x, rx]
          y: uy
        }
        {
          x: $in: [lx, x, rx]
          y: dy
        }
        {
          x: $in: [lx, rx]
          y: y
        }
      ]
  inverseState: ->
    if @document.state is 'on'
      'off'
    else
      'on'
  clone: ->
    new ConwayCell @document
  update: (documentFragment) ->
    Conway.cellCollection.update @document._id, $set: documentFragment 

this.Conway ?= {}

_.defaults Conway,
  geometry:
    width: 20
    height: 20
  cellCollection: new Meteor.Collection 'ConwayCell',
    transform: (document) ->
      new ConwayCell document
  cellCollectionPatch: new Meteor.Collection 'ConwayCellPatch',
    transform: (document) ->
      new ConwayCell document
  createFixtureRandom: ->
    Meteor.call 'reset', =>
      for y in [1..@geometry.height]
        for x in [1..@geometry.width]
          doc = {
            state: if Math.round(Math.random()) is 1 then 'on' else 'off'
            x: x
            y: y
          }
          Conway.cellCollection.insert doc
  createFixtureEmpty: ->
    Meteor.call 'reset', =>
      for y in [1..@geometry.height]
        for x in [1..@geometry.width]
          doc = {
            state: 'off'
            x: x
            y: y
          }
          Conway.cellCollection.insert doc
  updateCell: (cell) -> 
    cell
  play: ->
    if Meteor.isClient
      Session.set 'playing', true
      Meteor.call 'play'
    else
      throw new Error 'play() should only be called from the client'
  pause: ->
    if Meteor.isClient
      Session.set 'playing', false
      Meteor.call 'pause'
    else
      throw new Error 'pause() should only be called from the client'
  isPlaying: ->
    if Meteor.isClient
      Session.get('playing')
    else
      @playing


@addToPatch = (cellDocument) ->
  patchDocument = 
    applyTo: cellDocument._id
    state: cellDocument.state

  Conway.cellCollectionPatch.insert patchDocument 

@updateCells = (opinions = {}) ->
  for cell in Conway.cellCollection.find().fetch()
    if Conway.updateCell?(cell).changed
      @addToPatch cell.document
  Meteor.call 'applyPatch', opinions.finished

@applyPatch = ->
  for patch in Conway.cellCollectionPatch.find().fetch()
    {applyTo: applyTo, state: state} = patch.document
    Conway.cellCollection.update applyTo, $set: state: state
  Conway.cellCollectionPatch.remove {}


if Meteor.isServer
  Meteor.startup => 
    @isRunning = false
    Meteor.methods
      reset: (selector = {}) ->
        Conway.cellCollection.remove selector
        Conway.cellCollectionPatch.remove selector
      applyPatch: ->
        global.applyPatch()
      pause: =>
        @isRunning = false
      play: =>
        @isRunning = true
        
    Meteor.publish 'ConwayCell', (selector) ->
      Conway.cellCollection.find(selector)    

    always = -> true
    whenNotRunning = ->
      not @isRunning
    everything = insert: always, update: always, remove: always

    Conway.cellCollection.allow
      insert: whenNotRunning
      update: whenNotRunning
      remove: whenNotRunning
    Conway.cellCollectionPatch.allow everything

if Meteor.isClient
  Meteor.startup ->
    Meteor.subscribe 'ConwayCell', {}
    updateCellsInterval = null
    Conway.pause()
    Deps.autorun ->
      if Conway.isPlaying()
        finished = true 
        genCount = 0
        genInterval = 1000
        fn = ->
          if finished
            genCount++
            finished = false
            updateCells finished: ->
              finished = true
        updateCellsInterval = setInterval fn, genInterval
      else
        clearInterval updateCellsInterval

 

