{WorkspaceView} = require 'atom'
EmberCliHelper = require '../lib/ember-cli-helper'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "EmberCliHelper", ->
  activationPromise = null

  @content: ->
    @div class: 'ember-cli-helper tool-panel panel-bottom'
