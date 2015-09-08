{Task, BufferedProcess} = require 'atom'
{View} = require 'atom-space-pen-views'
GeneratorListView = require './generator-list-view'
path = require 'path'
fs = require 'fs'

module.exports =
class EmberCliHelperView extends View

  @content: ->
    @div class: 'ember-cli-helper tool-panel panel-bottom native-key-bindings', =>
      @div class: 'ember-cli-btn-group', =>
        @div class: 'block', =>
          @button outlet: 'switch',     click: 'switchFile',        class: 'btn btn-sm inline-block-tight',           'c/t'
          @button outlet: 'route',      click: 'switchRoute',       class: 'btn btn-sm inline-block-tight',           'r'
          @button outlet: 'server',     click: 'startServer',       class: 'btn btn-sm inline-block-tight',           'Server'
          @button outlet: 'test',       click: 'startTesting',      class: 'btn btn-sm inline-block-tight',           'Test'
          @button outlet: 'generate',   click: 'showGeneratorList', class: 'btn btn-sm inline-block-tight',           'Generate'
          @button outlet: 'exit',       click: 'stopProcess',       class: 'btn btn-sm inline-block-tight',           'Exit'
          @button outlet: 'hide',       click: 'toggle',            class: 'btn btn-sm inline-block-tight btn-right', 'Close'
          @button outlet: 'mini',       click: 'minimize',          class: 'btn btn-sm inline-block-tight btn-right', 'Minimize'
      @div outlet: 'panel', class: 'panel-body padded hidden', =>
        @ul outlet: 'messages', class: 'list-group'

  initialize: ->
    # Register Commands
    atom.commands.add 'atom-text-editor',
      "ember-cli-helper:toggle":         => @toggle()
      "ember-cli-helper:switch-file":    => @switchFile()
      "ember-cli-helper:switch-route":   => @switchRoute()
      "ember-cli-helper:open-component": => @openComponent()
      "ember-cli-helper:generate-file":  => @showGeneratorList()

    # Add the path to the Node executable to the $PATH
    nodePath = atom.config.get('ember-cli-helper.pathToNodeExecutable')
    nodePath = nodePath.substring(0, nodePath.length - 4)
    process.env.PATH += ":#{nodePath}"

    # Enable or disable the helper
    try
      ember = require("#{atom.project.getPaths()[0]}/package.json").devDependencies["ember-cli"]
    catch e
      error = e.code

    if ember?
      @generator = new GeneratorListView @
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
      atom.workspace.addBottomPanel
        item: this


  minimize: ->
    @panel.toggleClass 'hidden'

  getPathComponents: ->
    separator = path.sep
    editor = atom.workspace.getActivePaneItem()
    file = editor?.buffer.file
    fullPath = file?.getPath()
    fileName = file?.getBaseName()

    # must have a file with an extension under /app/*
    return [] if fileName.indexOf('.') == -1 || fullPath.split(separator).indexOf('app') == -1

    extension = path.extname(fileName)

    # TODO: choose only the last "app" folder
    pathUntilApp = fullPath.split(separator+'app'+separator)[0] + separator + 'app' + separator
    pathInApp = fullPath.split(separator+'app'+separator)[1].split(separator)
    pathInApp.pop()

    [pathUntilApp, pathInApp, fileName, extension]

  switchFile: ->
    [pathUntilApp, paths, fileName, extension] = @getPathComponents()
    return unless pathUntilApp

    separator = path.sep
    goodPaths = []

    # script to template
    if extension == '.coffee' || extension == '.js'
      newFileName = fileName.replace(/\.(js|coffee)$/, '.hbs')

      # components/*.js -> templates/components/*.hbs
      if paths[0] == 'components'
        goodPaths.push ["templates"].concat(paths).concat([newFileName]).join(separator)

      # controllers/*.js -> templates/*.hbs
      # routes/*.js -> templates/*.hbs
      else if paths[0] == 'controllers' || paths[0] == 'routes'
        paths.shift()
        goodPaths.push ["templates"].concat(paths).concat([newFileName]).join(separator)

    # template to script
    else if extension == '.hbs'
      newFileNameJs = fileName.replace(/\.hbs$/, '.js')
      newFileNameCoffee = fileName.replace(/\.hbs$/, '.coffee')

      # templates/components/*.hbs -> components/*.js
      if paths[0] == 'templates' && paths[1] == 'components'
        paths.shift()
        goodPaths.push paths.concat([newFileNameJs]).join(separator)
        goodPaths.push paths.concat([newFileNameCoffee]).join(separator)

      # templates/xyz/*.hbz -> controllers/
      else
        paths.shift()
        goodPaths.push ["controllers"].concat(paths).concat([newFileNameJs]).join(separator)
        goodPaths.push ["controllers"].concat(paths).concat([newFileNameCoffee]).join(separator)

    @openBestMatch(pathUntilApp, goodPaths)

  switchRoute: ->
    [pathUntilApp, paths, fileName, extension] = @getPathComponents()
    return unless pathUntilApp

    separator = path.sep
    goodPaths = []

    newFileNameJs = fileName.replace(/\.(js|coffee|hbs)$/, '.js')
    newFileNameCoffee = fileName.replace(/\.(js|coffee|hbs)$/, '.coffee')

    # script to template
    if extension == '.coffee' || extension == '.js'
      # routes/*.js -> controllers/*.js
      if paths[0] == 'routes'
        paths.shift()
        goodPaths.push ["controllers"].concat(paths).concat([newFileNameJs]).join(separator)
        goodPaths.push ["controllers"].concat(paths).concat([newFileNameCoffee]).join(separator)

      # controllers/*.js -> routes/*.js
      else if paths[0] == 'controllers'
        paths.shift()
        goodPaths.push ["routes"].concat(paths).concat([newFileNameJs]).join(separator)
        goodPaths.push ["routes"].concat(paths).concat([newFileNameCoffee]).join(separator)

    # template to script
    else if extension == '.hbs'
      # templates/(!components/)*.hbs -> routes/*.js
      if paths[0] == 'templates' && paths[1] != 'components'
        paths.shift()
        goodPaths.push ["routes"].concat(paths).concat([newFileNameJs]).join(separator)
        goodPaths.push ["routes"].concat(paths).concat([newFileNameCoffee]).join(separator)

    @openBestMatch(pathUntilApp, goodPaths)

  openComponent: ->
    [pathUntilApp, paths, fileName, extension] = @getPathComponents()
    return unless pathUntilApp

    separator = path.sep
    editor = atom.workspace.getActivePaneItem()

    cursor = editor.getCursorBufferPosition()
    line = editor.buffer.lines[cursor.row]

    startColumn = line.substring(0, cursor.column).lastIndexOf('{{')
    return if startColumn == -1

    line = line.substring(startColumn + 2)
    line = line.substring(1) if line.indexOf('#') == 0

    componentName = line.split(/[^A-Za-z0-9\/\-_]/)[0]

    if componentName && componentName.indexOf('-') > 0
      templateName = "templates/components/"+componentName.replace('/', separator)+".hbs"
      @openBestMatch(pathUntilApp, [templateName])


  openBestMatch: (pathUntilApp, goodPaths) ->
    legitPaths = goodPaths.filter (pathToTry) =>
      fs.existsSync(pathUntilApp + pathToTry)

    bestPath = legitPaths[0] || goodPaths[0]
    if bestPath
      atom.workspace.open(pathUntilApp + bestPath)

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
    @generator.show() if @generator


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
  addLine: (text, type = "plain") ->
    [panel, messages] = [@panel, @messages]
    text = text.trim().replace /[\r\n]+/g, '<br />'
    stuckToBottom = messages.height() - panel.height() - panel.scrollTop() == 0
    messages.append "<li class='text-#{type}'>#{text}</li>"
    panel.scrollTop messages.height() if stuckToBottom

  clearPanel: ->
    @messages.empty()
