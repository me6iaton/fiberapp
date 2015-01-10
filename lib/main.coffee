git = httpServer = null
generatorFactory = require './generators/generator'
path = require 'path'
fs = require 'fs'

projectPath = path.resolve(atom.config.resourcePath, '../../project')

if fs.lstatSync(projectPath).isSymbolicLink()
  projectPath = fs.readlinkSync(projectPath)
  if process.platform == 'win32'
    projectPath = atom.config.resourcePath.slice(0, 1).toLowerCase() + projectPath.slice(1)

console.time('fs.existsSync')
for confname in ['config.toml', 'docpad.coffee', '_config.yml']
  if fs.existsSync path.resolve(projectPath, './' + confname )
    generatorName = switch confname
      when 'config.toml' then 'hugo'
      when 'docpad.coffee' then 'docpad'
      when '_config.yml' then 'hexo'
    break
console.timeEnd('fs.existsSync')

generator = generatorFactory(generatorName)

module.exports =
  config:
    projectPath:
      type: 'string'
      default: projectPath
    srcPath:
      type: 'string'
      default: path.resolve(projectPath, generator.config.srcPath)
    documentsPath:
      type: 'string'
      default: path.resolve(projectPath, generator.config.documentsPath)
    outPath:
      type: 'string'
      default: path.resolve(projectPath, generator.config.outPath)
    mode:
      type: 'string'
      default: 'production'
    previewSplitRight:
      type: 'boolean'
      default: true
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
      default: generatorName
    serverHost:
      type: 'string'
      default: 'localhost'
    serverPort:
      type: 'number'
      default: '9778'


  activate: (state) ->
    @generator = generator
    atom.packages.onDidActivateAll () =>
      git = require './git'
      httpServer = require './http-server'

      # add atom.nprogress
      atom.nprogress = require 'nprogress'
      atom.nprogress.configure({
        parent : '.tab-bar'
        ,showSpinner: false
      })

      git.checkAvailability()
      @setMode(atom.config.get 'docapp.mode')

      atom.workspaceView.command "docapp:deploy-ghpages", -> @generator.deployGhpages()
      atom.workspaceView.command "docapp:preview", ->  @generator.togglePreview()

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
