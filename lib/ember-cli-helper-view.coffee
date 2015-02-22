{View, Task, BufferedProcess} = require 'atom'
GeneratorListView = require './generator-list-view'

module.exports =
class EmberCliHelperView extends View

  @content: ->
    @div class: 'ember-cli-helper tool-panel panel-bottom native-key-bindings', =>
      @div class: 'ember-cli-btn-group', =>
        @div class: 'block', =>
          @button outlet: 'server',   click: 'startServer',       class: 'btn btn-sm inline-block-tight', =>
            @span 'Server '
            @span outlet: 'serverMark', "\u25CF"
          @button outlet: 'test',     click: 'startTesting',      class: 'btn btn-sm inline-block-tight',           'Test'
          @button outlet: 'generate', click: 'showGeneratorList', class: 'btn btn-sm inline-block-tight',           'Generate'
          @button outlet: 'exit',     click: 'stopProcess',       class: 'btn btn-sm inline-block-tight',           'Exit'
          @button outlet: 'hide',     click: 'toggle',            class: 'btn btn-sm inline-block-tight btn-right', 'Close'
          @button outlet: 'mini',     click: 'minimize',          class: 'btn btn-sm inline-block-tight btn-right', 'Minimize'
      @div outlet: 'panel', class: 'panel-body padded hidden', =>
        @ul outlet: 'messages', class: 'list-group'

  initialize: ->
    @lastColor = null
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
      args    = [task,"--color"]
      proxyArg = atom.config.get('ember-cli-helper.proxyUrl')
      if task == 'server' && proxyArg != ''
        args.push("--proxy")
        args.push(proxyArg)
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
  updateServerButton: ->
    @serverMark.attr 'class', @lastColor



  showGeneratorList: ->
    generators = new GeneratorListView @


  runGenerator: (query)->
    @minimize() if @panel.hasClass 'hidden'
    command = atom.config.get('ember-cli-helper.pathToEmberExecutable')

    # Set up args (generator to run)
    args = ['generate']
    args = args.concat query
    args.push 'coffee:true' if atom.config.get 'ember-cli-helper.generateCoffeescript'

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
  addLine: (text) ->
    [panel, messages] = [@panel, @messages]
    text = text.replace /\ /g, '&nbsp;'
    text = @colorize text
    text = @stripColorCodes text
    text = text.trim().replace /[\r\n]+/g, '<br />'
    stuckToBottom = messages.height() - panel.height() - panel.scrollTop() <= 0
    messages.append "<li class='text'>#{text}</li>"
    @updateServerButton()
    panel.scrollTop messages.height() if stuckToBottom
  colorize:(text) ->
    self = this
    text = text.replace /\[([0-9]*)m(.+?)(\[.+?)/g,(string, code, intext, outtext) ->
        color = null
        switch code
          when '1' then color = 'strong'
          when '4' then color = 'underline'
          when '31' then color = 'red'
          when '32' then color = 'green'
          when '33' then color = 'yellow'
          when '36' then color = 'cyan'
          when '90' then color = 'gray'
        if color
          self.lastColor = color if code != '1' && code != '4'
          "<span class='#{color}'>#{intext}</span>#{outtext}"
        else
          "#{intext}#{outtext}"

    return text
  stripColorCodes:(text) ->
    return text.replace /\[[0-9]{1,2}m/g, ''
  clearPanel: ->
    @messages.empty()
