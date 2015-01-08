git = generatorFactory = httpServer = null
path = require 'path'
fs = require 'fs'

if process.platform == 'win32'
  projectPath = path.resolve(atom.config.resourcePath, '../../project')
else
  projectPath = path.resolve(atom.config.resourcePath, '../../../project')

if fs.lstatSync(projectPath).isSymbolicLink()
  projectPath = fs.readlinkSync(projectPath)
  if process.platform == 'win32'
    projectPath = atom.config.resourcePath.slice(0, 1).toLowerCase() + projectPath.slice(1)

module.exports =
  config:
    rootPath:
      type: 'string'
      default: projectPath
    mode:
      type: 'string'
      default: 'production'
    previewSplitRight:
      type: 'boolean'
      default: true
    srcPath:
      type: 'string'
      default: path.resolve(projectPath, './src')
    documentsPath:
      type: 'string'
      default: path.resolve(projectPath, './src/render')
    outPath:
      type: 'string'
      default: path.resolve(projectPath, './out')
    gitPath:
      type: 'string'
      default: 'git'
      description: 'Where is your git?'
    gitDeployUrl:
      type: 'string'
      default: 'https://me6iaton:4e88254dc719d7f4df5b8e759e5c3919cdeca9d0@github.com/me6iaton/docapp-ghpages-test.git'
    gitSetDeployUrl:
      type: 'boolean'
      default: false
    environment:
      type: 'string'
      default: 'dev'
    generator:
      type: 'string'
      default: 'docpad'
    serverHost:
      type: 'string'
      default: 'localhost'
    serverPort:
      type: 'number'
      default: '9778'


  activate: (state) ->
    atom.packages.onDidActivateAll () =>

      git = require './git'
      generatorFactory = require './generators/generator'
      httpServer = require './http-server'

      # add atom.nprogress
      atom.nprogress = require 'nprogress'
      atom.nprogress.configure({
        parent : '.tab-bar'
        ,showSpinner: false
      })

      @setMode(atom.config.get 'docapp.mode')
      git.checkAvailability()
      @generator = generatorFactory atom.config.get 'docapp.generator'

      atom.workspaceView.command "docapp:deploy-ghpages", => @generator.deployGhpages()
      atom.workspaceView.command "docapp:preview", =>  @generator.togglePreview()

      atom.on 'merge-conflicts:done', (event) =>
        git.gitCmd args: ['rebase', '--continue']
        .then () =>
          @generator.deployGhpages()

#      httpServer.runChildProcess
#        root: atom.config.get('docapp.outPath')
#        address: atom.config.get('docapp.serverAddress')
#        port: atom.config.get('docapp.serverPort')

      httpServer.run
        root: atom.config.get('docapp.outPath')
        host: atom.config.get('docapp.serverHost')
        port: atom.config.get('docapp.serverPort')

#      @generator.run()
#      @generator.runChild()

  setMode: (mode)->
    # todo-me refactor setMode -> pathsLength
    pathsLength = atom.project.getPaths().length
    if pathsLength == 0
      if mode == 'production'
        atom.project.setPaths([atom.config.get 'docapp.srcPath'])
      else if mode == 'dev'
        atom.project.setPaths([atom.config.get 'docapp.rootPath'])
    pathsLength = 1

  deactivate: ->

  serialize: ->
