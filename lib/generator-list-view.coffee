{SelectListView, BufferedProcess} = require 'atom'
ParamListView = require './generator-param-view'

module.exports = class GeneratorListView extends SelectListView

  @selected = false

  blueprints: []

  initialize: (@view)->
    super
    @addClass 'overlay from-top'
    @getBlueprints()


  viewForItem: (item) ->
    "<li>#{item}</li>"


  confirmed: (item) ->
    @storeFocusedElement()
    new ParamListView @view, item


  getEmptyMessage: ->
    "Select a type to generate"


  stdoutIteration: 0
  getBlueprints: ->
    command = atom.config.get('ember-cli-helper.pathToEmberExecutable')
    args = ['generate', '--help']
    options =
      cwd: atom.project.getPaths()[0] + atom.config.get('ember-cli-helper.emberProjectPath')
    stdout = (out)=>
      outArray = out.split('\n')
      outArray.forEach (line)=>
        console.debug line
        if line.match(/.*(?=\s<name>)/) && line.match(/^\s{6}/)
          @blueprints.push line.substring(6, line.length - 1)

    exit = (code)=>
      @setItems @blueprints
      atom.workspaceView.append(this)
      @focusFilterEditor()
    try
      new BufferedProcess({command, args, options, stdout, exit})
    catch e
      console.error e



