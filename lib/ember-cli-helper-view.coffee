{View, Task, BufferedProcess} = require 'atom'
GeneratorListView = require './generator-list-view'

module.exports =
class EmberCliHelperView extends View

  @content: ->
    @div class: 'ember-cli-helper tool-panel panel-bottom native-key-bindings', =>
      @div class: 'ember-cli-btn-group', =>
        @button outlet: 'server', click: 'startServer', class: 'btn', 'Server'
        @button outlet: 'test', click: 'startTesting', class: 'btn', 'Test'
        @button outlet: 'generate', click: 'showGeneratorList', class: 'btn', 'Generate'
        @button outlet: 'exit', click: 'stopProcess', class: 'btn', 'Exit'
        @button outlet: 'hide', click: 'toggle', class: 'btn btn-right', 'Close'
        @button outlet: 'mini', click: 'minimize', class: 'btn btn-right', 'Minimize'
      @div outlet: 'panel', class: 'panel-body padded hidden', =>
        @ul outlet: 'messages', class: 'list-group'

  initialize: ->
    # Register Commands
    atom.workspaceView.command "ember-cli-helper:toggle", => @toggle()
    atom.workspaceView.command "ember-cli-helper:generate-file", => @showGeneratorList()

    # Enable or disable the helper
    try
      ember = require("#{atom.project.getPath()}/package.json").devDependencies["ember-cli"]
    catch e
      error = e.code

    if ember?
      @toggle()
    else
      @emberProject = false
      @addLine "This is not an Ember CLI projet!"


  # Returns an object that can be retrieved when package is activated
  serialize: ->


  # Tear down any state and detach
  destroy: ->
    @stopProcess()
    @clearPanel()
    @panel.removeClass 'hidden'
    @detach()


  toggle: ->
    if @hasParent()
      @destroy()
    else
      atom.workspaceView.prependToBottom this


  minimize: ->
    @panel.toggleClass 'hidden'


  startServer: ->
    @runCommand 'Ember CLI Server Started'.fontcolor("green"), 'server'


  startTesting: ->
    @runCommand 'Ember CLI Testing Started'.fontcolor("green"), 'test'


  runCommand: (message, task) ->
    if @lastProcess == task
      @minimize()
    else
      @stopProcess()
      @lastProcess = task
      @minimize() if @panel.hasClass 'hidden'
      @clearPanel()
      @addLine message
      stdout = (out) ->
        @addLine out
      exit = (code) ->
        atom.beep() unless code == 0
        @addLine "Ember CLI exited: code #{code}"
      try
        @process = new BufferedProcess
          command: 'ember'
          args: [task]
          options: {cwd: atom.project.getPath()}
          stdout: stdout.bind @
          exit: exit.bind @
      catch e
        @addLine "There was an error running the script"


  stopProcess: ->
    console.debug @process
    if @process?
      @process.kill()
      @process = null
      @addLine "Ember CLI Stopped".fontcolor("red")


  showGeneratorList: ->
    generators = new GeneratorListView @


  runGenerator: (query)->
    @minimize() if @panel.hasClass 'hidden'
    stdout = (out)->
      @addLine out.fontcolor("orange")
    exit = (code) ->
      atom.beep() unless code == 0
    args = ['generate', query, "type:object"]
    args.push "coffee:true" if atom.config.get 'ember-cli-helper.generateCoffeescript'
    try
      @process = new BufferedProcess
        command: 'ember'
        args: args
        options: {cwd: atom.project.getPath()}
        stdout: stdout.bind @
        exit: exit.bind @
    catch e
      @addLine "Error: #{e}"


  # Borrowed from grunt-runner by @nickclaw
  # https://github.com/nickclaw/atom-grunt-runner
  addLine: (text, type = "plain") ->
    [panel, messages] = [@panel, @messages]
    text = text.trim().replace /[\r\n]+/g, '<br />'
    stuckToBottom = messages.height() - panel.height() - panel.scrollTop() == 0
    messages.append "<li class='text-#{type}'>#{text}</li>"
    panel.scrollTop messages.height() if stuckToBottom

  clearPanel: ->
    @messages.empty()
