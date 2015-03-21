{SelectListView} = require 'atom-space-pen-views'

module.exports = class GeneratorParamView extends SelectListView

  content: ->
    @div 'This is a test'


  initialize: (@view, @type)->
    super

    @addClass 'overlay from-top'
    @setItems []

    @storeFocusedElement()
    @panel ?= atom.workspace.addModalPanel(item: this)

    @filterEditorView.on 'keydown', (event)=>
      if event.keyCode == 13
        @confirm()

    @panel.show()
    @focusFilterEditor()


  viewForItem: -> ""


  confirm: ->
    name = @getFilterQuery()
    @cancel()
    @view.runGenerator [@type, name]


  getEmptyMessage: ->
    "Enter the name of the #{@type} to generate"


  hide: ->
    @panel?.hide()

  cancelled: ->
    @hide()
