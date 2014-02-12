
this.Conway ?= {}

_.extend Conway,
  persistentCellCollection: new Meteor.Collection 'ConwayCell',
    transform: (document) ->
      new Conway.Cell document
  createFixture: (options = {}) ->
    @persistentCellCollection.remove {}
    for y in [1..@geometry.height]
      for x in [1..@geometry.width]
        @persistentCellCollection.insert
          _id: "#{x},#{y}"
          state:
            alive: options.randomize and Math.round(Math.random()) is 1
          stage: 2
          x: x
          y: y
  save: (cellCollection) ->
    for doc in cellCollection
      data = _(doc).omit '_id'
      @persistentCellCollection.update doc._id, data


Meteor.startup =>
  Meteor.methods
    reset: (selector = {}) ->
      Conway.persistentCellCollection.remove selector
    save: (cellCollection) ->
      console.log arguments
      Conway.save(cellCollection)
    createFixture: (options) ->
      Conway.createFixture(options)
      
  Meteor.publish 'ConwayCell', (selector) ->
    Conway.persistentCellCollection.find(selector)

  always = -> true
  everything = insert: always, update: always, remove: always

  Conway.persistentCellCollection.allow everything

  # Conway.createFixture()
