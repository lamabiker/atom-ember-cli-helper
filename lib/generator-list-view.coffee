{$$, SelectListView} = require 'atom-space-pen-views'
GeneratorNameView = require './generator-name-view'

module.exports = class GeneratorListView extends SelectListView

  initialize: (@view)->
    super
    @addClass 'overlay from-top'
    @setItems ['component', 'controller', 'helper', 'mixin', 'route', 'template', 'view']


  viewForItem: (item) ->
    $$ ->
      @li item


  confirmed: (item) ->
    new GeneratorNameView(@view, item)
    @cancel()


  getEmptyMessage: ->
    "Select a type to generate"


  show: ->
    @storeFocusedElement()
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @focusFilterEditor()


  hide: ->
    @panel?.hide()


  cancelled: ->
    @hide()
