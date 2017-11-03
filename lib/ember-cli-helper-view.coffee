{Task, BufferedProcess} = require 'atom'
{$, View} = require 'atom-space-pen-views'
GeneratorListView = require './generator-list-view'
{TEMPLATE_EXTENSIONS, SCRIPT_EXTENSIONS} = require './constants'
path = require 'path'
fs = require 'fs'

module.exports =
class EmberCliHelperView extends View

  @content: ->
    @div class: 'ember-cli-helper native-key-bindings', =>
      @div class: 'ember-cli-resize-handle', outlet: 'resizeHandle'
      @div class: 'ember-cli-btn-group', outlet: 'buttonGroup', =>
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
      "ember-cli-helper:switch-style":   => @switchStyle()
      "ember-cli-helper:open-component": => @openComponent()
      "ember-cli-helper:generate-file":  => @showGeneratorList()

    # Set up panel resizing
    @on 'mousedown', '.ember-cli-resize-handle', (e) => @resizeStarted(e)

    # Add the path to the Node executable to the $PATH
    nodePath = atom.config.get('ember-cli-helper.pathToNodeExecutable')
    nodePath = nodePath.substring(0, nodePath.length - 4)
    process.env.PATH += ":#{nodePath}"

    # Enable or disable the helper
    try
      ember = require("#{@getEmberProjectPath()}/package.json").devDependencies["ember-cli"]
    catch e
      error = e.code

    if ember?
      @generator = new GeneratorListView @
      @toggle()
    else
      @emberProject = false
      @addLine "This is not an Ember CLI projet in #{@getEmberProjectPath()}"
      @panel.removeClass 'hidden'


  getEmberProjectPath: ->
    atom.project.getPaths()[0] + atom.config.get('ember-cli-helper.emberProjectPath')

  getEmberPath: ->
    atom.config.get('ember-cli-helper.pathToEmberExecutable')

  # Returns an object that can be retrieved when package is activated
  serialize: ->


  # Tear down any state and detach
  destroy: ->
    @stopProcess()
    @clearPanel()
    @resizeStopped()
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


  # panel resizing code based on atom's tree-view package
  resizeStarted: =>
    $(document).on('mousemove', @resizePanel)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: =>
    $(document).off('mousemove', @resizePanel)
    $(document).off('mouseup', @resizeStopped)

  resizePanel: ({pageY, which}) =>
    return @resizeStopped() unless which is 1
    height = @outerHeight() + @offset().top - pageY
    barHeight = @buttonGroup.height();
    @panel.innerHeight(height - barHeight);


  getPathComponents: ->
    separator = path.sep
    editor = atom.workspace.getActivePaneItem()
    file = editor?.buffer.file
    fullPath = file?.getPath()
    fileName = file?.getBaseName()

    # must have a file with an extension under /app/*
    return [] if !fileName || fileName.indexOf('.') == -1 || fullPath.split(separator).indexOf('app') == -1

    extension = path.extname(fileName).replace('.', '')

    # TODO: choose only the last "app" folder
    pathUntilApp = fullPath.split(separator+'app'+separator)[0] + separator + 'app' + separator
    pathInApp = fullPath.split(separator+'app'+separator)[1].split(separator)
    pathInApp.pop()

    [pathUntilApp, pathInApp, fileName, extension]

  generatePossiblePaths: (basePaths, fileName, possibleExtensions) ->
    baseFileName = fileName.substring(0, fileName.lastIndexOf('.')) || fileName
    possiblePaths = for ext in possibleExtensions
      basePaths.concat(["#{baseFileName}.#{ext}"]).join(path.sep)

  switchFile: ->
    [pathUntilApp, paths, fileName, extension] = @getPathComponents()
    return unless pathUntilApp

    possiblePaths = []

    # script to template
    if extension in SCRIPT_EXTENSIONS
      # components/*.js -> templates/components/*.hbs
      if paths[0] == 'components'
        basePaths = ["templates"].concat(paths)
        possiblePaths = @generatePossiblePaths(basePaths, fileName, TEMPLATE_EXTENSIONS)

      # controllers/*.js -> templates/*.hbs
      # routes/*.js -> templates/*.hbs
      else if paths[0] == 'controllers' || paths[0] == 'routes'
        paths.shift()
        basePaths = ["templates"].concat(paths)
        possiblePaths = @generatePossiblePaths(basePaths, fileName, TEMPLATE_EXTENSIONS)

    # template to script
    else if extension in TEMPLATE_EXTENSIONS
      # templates/components/*.hbs -> components/*.js
      if paths[0] == 'templates' && paths[1] == 'components'
        paths.shift()
        possiblePaths = @generatePossiblePaths(paths, fileName, SCRIPT_EXTENSIONS)

      # templates/xyz/*.hbz -> controllers/
      else
        paths.shift()
        basePaths = ["controllers"].concat(paths)
        possiblePaths = @generatePossiblePaths(basePaths, fileName, SCRIPT_EXTENSIONS)

    @openBestMatch(pathUntilApp, possiblePaths)

  switchRoute: ->
    [pathUntilApp, paths, fileName, extension] = @getPathComponents()
    return unless pathUntilApp

    separator = path.sep
    possiblePaths = []

    # script to template
    if extension in SCRIPT_EXTENSIONS
      # routes/*.js -> controllers/*.js
      if paths[0] == 'routes'
        paths.shift()
        basePaths = ["controllers"].concat(paths)
        possiblePaths = @generatePossiblePaths(basePaths, fileName, TEMPLATE_EXTENSIONS)

      # controllers/*.js -> routes/*.js
      else if paths[0] == 'controllers'
        paths.shift()
        basePaths = ["routes"].concat(paths)
        possiblePaths = @generatePossiblePaths(basePaths, fileName, TEMPLATE_EXTENSIONS)

    # template to script
    else if extension in TEMPLATE_EXTENSIONS
      # templates/(!components/)*.hbs -> routes/*.js
      if paths[0] == 'templates' && paths[1] != 'components'
        paths.shift()
        basePaths = ["routes"].concat(paths)
        possiblePaths = @generatePossiblePaths(basePaths, fileName, SCRIPT_EXTENSIONS)

    @openBestMatch(pathUntilApp, possiblePaths)

  switchStyle: ->
    [pathUntilApp, paths, fileName, extension] = @getPathComponents()
    return unless pathUntilApp

    separator = path.sep
    goodPaths = []

    newFileNameSass = fileName.replace(/\.(js|coffee|hbs)$/, '.sass')

    # style to template
    if extension == '.sass'
      newFileName = fileName.replace(/\.(sass)$/, '.hbs')

      # styles/components/*.sass -> templates/components/*.hbs
      if paths[0] == 'styles' && paths[1] == 'components'
        paths.shift()
        goodPaths.push ['templates'].concat(paths).concat([newFileName]).join(separator)

    # template to style
    else if extension == '.hbs'
      # templates/components/*.hbs -> styles/components/*.sass
      if paths[0] == 'templates' && paths[1] == 'components'
        paths.shift()
        paths.unshift('styles')
        goodPaths.push paths.concat([newFileNameSass]).join(separator)

    @openBestMatch(pathUntilApp, goodPaths)

  openComponent: ->
    [pathUntilApp, paths, fileName, extension] = @getPathComponents()
    return unless pathUntilApp

    separator = path.sep
    editor = atom.workspace.getActivePaneItem()

    cursor = editor.getCursorBufferPosition()
    line = editor.buffer.lineForRow(cursor.row)

    startColumn = line.substring(0, cursor.column).lastIndexOf('{{')
    return if startColumn == -1

    line = line.substring(startColumn + 2)
    line = line.substring(1) if line.indexOf('#') == 0

    componentName = line.split(/[^A-Za-z0-9\/\-_]/)[0]

    if componentName && componentName.indexOf('-') > 0
      basePaths = ["templates", "components"]
      fileNameParts = componentName.split("/")
      fileName = fileNameParts.pop()
      basePaths = basePaths.concat(fileNameParts)
      possiblePaths = @generatePossiblePaths(basePaths, fileName, TEMPLATE_EXTENSIONS)

      @openBestMatch(pathUntilApp, possiblePaths)


  openBestMatch: (pathUntilApp, goodPaths) ->
    legitPaths = goodPaths.filter (pathToTry) =>
      fs.existsSync(pathUntilApp + pathToTry)

    bestPath = legitPaths[0] || goodPaths[0]
    if bestPath
      atom.workspace.open(pathUntilApp + bestPath, { searchAllPanes: true })

  startServer: ->
    serverParameters = atom.config.get('ember-cli-helper.emberServerParameters')
    @runCommand 'Ember CLI Server Started'.fontcolor("green"), 'server', serverParameters


  startTesting: ->
    @runCommand 'Ember CLI Testing Started'.fontcolor("green"), 'test'


  runCommand: (message, task, params) ->
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

      command = @getEmberPath()
      args = if params then params.split(' ') else []
      args.unshift task
      options =
        cwd: @getEmberProjectPath()
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
    if @generator
      try
        @generator.show()
      catch e
        @addLine "Trobule opening the generator list. Make sure your project (#{@getEmberProjectPath()}) and ember-cli (#{@getEmberPath()}) are properly configured".fontcolor("red")
        @panel.removeClass 'hidden'
    else
      @addLine "Could not find ember project in #{@getEmberProjectPath()} (ember-cli: #{@getEmberPath()})".fontcolor("red")
      @panel.removeClass 'hidden'

  runGenerator: (query)->
    @minimize() if @panel.hasClass 'hidden'
    command = @getEmberPath()

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
