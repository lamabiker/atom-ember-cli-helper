{BufferedProcess} = require 'atom'
{$$, SelectListView} = require 'atom-space-pen-views'
GeneratorNameView = require './generator-name-view'

module.exports = class GeneratorListView extends SelectListView

  initialize: (@view)->
    super
    @addClass 'overlay from-top'

    # Generate list of blueprints from Ember executable
    @getBlueprints()
    .catch (err)->
      throw err
    .then (prints)=>
      # ::show uses this variable to populate the list of items
      @blueprints = prints.sort()


  viewForItem: (item) ->
    $$ ->
      @li item


  confirmed: (item) ->
    new GeneratorNameView(@view, item)
    @cancel()


  getEmptyMessage: -> "Select a type to generate"


  show: ->
    @storeFocusedElement()
    @panel ?= atom.workspace.addModalPanel(item: this)
    @setItems @blueprints
    @panel.show()
    @focusFilterEditor()


  # Needed for hiding the list of generators
  hide: -> @panel?.hide()

  cancelled: -> @hide()

  destroy: ->
    @cancel()
    @panel?.destroy()


  # Dynamically generate the list of blueprints
  getBlueprints: ->
    new Promise (resolve, reject)->

      # Array of blueprints
      blueprints = []

      # Set up the command options
      command = atom.config.get('ember-cli-helper.pathToEmberExecutable')
      args = ['generate', '--help']
      options =
        cwd: atom.project.getPaths()[0] + atom.config.get('ember-cli-helper.emberProjectPath')
      stdout = (out)->
        outArray = out.split('\n')
        outArray.forEach (line)->
          if line.match(/.*(?=\s<name>)/) && line.match(/^\s{6}/)
            command = line.trim().split(" ")[0]
            blueprints.push command
      exit = (code)->
        if (code != 0)
          reject new Error("There was a problem reading the generator options")
        else
          resolve blueprints

      try
        new BufferedProcess({command, args, options, stdout, exit})
      catch e
        reject(e)
