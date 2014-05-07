EmberCliHelperView = require './ember-cli-helper-view'

module.exports =
  emberCliHelperView: null

  activate: (state = {}) ->
    @emberCliHelperView = new EmberCliHelperView(state.emberCliHelperViewState)

  deactivate: ->
    @emberCliHelperView.stopProcess()
    @emberCliHelperView.destroy()

  serialize: ->
    emberCliHelperViewState: @emberCliHelperView.serialize()
