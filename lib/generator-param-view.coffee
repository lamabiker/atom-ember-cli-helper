{SelectListView} = require 'atom'
GeneratorTypeView = require './generator-type-view'

module.exports = class GeneratorParamView extends SelectListView


  initialize: (@view, @param)->
    super
    @addClass 'overlay from-top'
    @setItems []
    this.filterEditorView.on 'keydown', (event)=>
      if event.keyCode == 13
        @runCommand()
    atom.workspaceView.append(this)
    @focusFilterEditor()


  confirmed: (item)->
    console.debug item


  viewForItem: (item) ->
    "<li>#{item}</li>"


  getEmptyMessage: ->
    "Enter the name of the #{@param} to generate"


  runCommand: ->
    if @param == 'controller'
      new GeneratorTypeView @view, [@param, @getFilterQuery()]
    else
      @view.runGenerator [@param, @getFilterQuery()]
