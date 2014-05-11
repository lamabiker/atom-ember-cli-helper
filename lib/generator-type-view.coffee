{SelectListView} = require 'atom'

module.exports = class GeneratorTypeView extends SelectListView


  initialize: (@view, @param)->
    super
    @addClass 'overlay from-top'
    @setItems ['object', 'array', 'neither']
    atom.workspaceView.append(this)
    @focusFilterEditor()


  confirmed: (item)->
    @view.runGenerator "#{@param} #{item}"
    @cancel()


  viewForItem: (item) ->
    "<li>#{item}</li>"


  getEmptyMessage: ->
    "Choose which type of #{@param.slit(' ')[0]} you want to create"
