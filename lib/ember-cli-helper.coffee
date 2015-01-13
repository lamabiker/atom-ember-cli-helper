EmberCliHelperView = require './ember-cli-helper-view'

module.exports =
  emberCliHelperView: null

  config:
    generateCoffeescript:
      type: 'boolean'
      default: false

    pathToNodeExecutable:
      type: 'string'
      default: '/usr/local/bin/node'

    pathToEmberExecutable:
      type: 'string'
      default: '/usr/local/bin/ember'


  activate: (state = {}) ->
    @emberCliHelperView = new EmberCliHelperView(state.emberCliHelperViewState)

  deactivate: ->
    @emberCliHelperView.stopProcess()
    @emberCliHelperView.destroy()

  serialize: ->
    emberCliHelperViewState: @emberCliHelperView.serialize()
