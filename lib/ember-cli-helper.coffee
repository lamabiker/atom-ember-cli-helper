EmberCliHelperView = require './ember-cli-helper-view'

module.exports =
  emberCliHelperView: null

  config:
    enableHelper:
      title: 'Enable Helper'
      description: 'Enable console and helper buttons'
      type: 'boolean'
      default: true

    generateCoffeescript:
      title: 'Generate CoffeeScript'
      description: 'Enable to generate CoffeeScript files instead of JavaScript'
      type: 'boolean'
      default: false

    pathToNodeExecutable:
      title: 'Path to Node Executable'
      description: """
        For the package to work correctly, you need to specify the path to node
        on your computer
        """
      type: 'string'
      default: '/usr/local/bin/node'

    pathToEmberExecutable:
      title: 'Path to Ember Executable'
      description: """
        For the package to work correctly, you need to specify the path to the
        global ember executable on your computer
        """
      type: 'string'
      default: '/usr/local/bin/ember'

    emberProjectPath:
      title: 'Ember Project Path (relative)'
      description: """
        Change only if your Ember project is not in the root of your project,
        i.e. if the Ember project is a subdirectory of the directory that's
        currently open in Atom. Particularly useful with project-manager, where
        you can change settings on a per-project basis. Restart atom after changing this.
        """
      type: 'string'
      default: '/'

    emberServerParameters:
      title: 'Ember Server Parameters'
      description: """
        Additional parameters to pass to the 'ember server' command.
        """
      type: 'string'
      default: ''


  activate: (state = {}) ->
    @emberCliHelperView = new EmberCliHelperView(state.emberCliHelperViewState)

  deactivate: ->
    @emberCliHelperView.stopProcess()
    @emberCliHelperView.destroy()

  serialize: ->
    emberCliHelperViewState: @emberCliHelperView.serialize()
