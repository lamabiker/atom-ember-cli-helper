{SelectListView} = require 'atom'
ParamListView = require './generator-param-view'

module.exports = class GeneratorListView extends SelectListView

  @selected = false

  initialize: (@view)->
    super
    @addClass 'overlay from-top'
    @setItems ['component', 'controller', 'helper', 'mixin', 'route', 'template', 'view']
    atom.workspaceView.append(this)
    @focusFilterEditor()


  viewForItem: (item) ->
    "<li>#{item}</li>"


  confirmed: (item) ->
    @storeFocusedElement()
    new ParamListView @view, item


  getEmptyMessage: ->
    "Select a type to generate"
