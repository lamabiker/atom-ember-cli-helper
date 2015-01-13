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

    # Add the path to the Node executable to the $PATH
    nodePath = atom.config.get('ember-cli-helper.pathToNodeExecutable')
    nodePath = nodePath.substring(0, nodePath.length - 4)
    process.env.PATH += ":#{nodePath}"

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
      if task == 'server'
        @server.addClass 'active'
      if task == 'test'
        @test.addClass 'active'
      @minimize() if @panel.hasClass 'hidden'
      @clearPanel()
      @addLine message

      command = atom.config.get('ember-cli-helper.pathToEmberExecutable')
      args    = [task]
      options =
        cwd: atom.project.getPaths()[0] + atom.config.get('ember-cli-helper.emberProjectPath')
      stdout = (out)=> @addLine out
      stderr = (out)=> @addLine out.fontcolor('red')
      exit = (code)=>
        atom.beep() unless code == 0
        @addLine "Ember CLI exited: code #{code}"
        @removeActiveLabel()
      try
        @process = new BufferedProcess({command, args, options, stdout, stderr, exit})
      catch e
        @addLine "There was an error running the script"


  stopProcess: ->
    @process?.kill()
    if @process?.killed
      @removeActiveLabel()
      @process = null
      @addLine "Ember CLI Stopped".fontcolor("red")


  removeActiveLabel: ->
    if @lastProcess == 'server'
      @server.removeClass 'active'
    if @lastProcess == 'test'
      @test.removeClass 'active'
    @lastProcess = null


  showGeneratorList: ->
    generators = new GeneratorListView @


  runGenerator: (query)->
    @minimize() if @panel.hasClass 'hidden'
    command = atom.config.get('ember-cli-helper.pathToEmberExecutable')
    args = ['generate', query, "type:object"]
    args.push "coffee:true" if atom.config.get 'ember-cli-helper.generateCoffeescript'
    options =
      cwd: atom.project.getPaths()[0] + atom.config.get('ember-cli-helper.emberProjectPath')
    stdout = (out)=> @addLine out.fontcolor("orange")
    exit = (code)-> atom.beep() unless code == 0
    try
      @process = new BufferedProcess({command, args, options, stdout, exit})
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
