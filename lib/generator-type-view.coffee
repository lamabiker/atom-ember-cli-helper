{SelectListView} = require 'atom'

module.exports = class GeneratorTypeView extends SelectListView


  initialize: (@view, @param)->
    super
    @addClass 'overlay from-top'
    @setItems ['object', 'array', 'neither']
    atom.workspaceView.append(this)
    @focusFilterEditor()


  confirmed: (item)->
    @param.push item
    @view.runGenerator @param
    @cancel()


  viewForItem: (item) ->
    "<li>#{item}</li>"


  getEmptyMessage: ->
    "Choose which type of #{@param[0]} you want to create"
