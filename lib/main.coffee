{CompositeDisposable} = require 'atom'
git = httpServer = null
generatorFactory = require './generators/generator'
path = require 'path'
fs = require 'fs'

# projectPath
if process.platform == 'darwin'
  resolvePath = '../../../project'
else
  resolvePath = '../../project'
projectPath = path.resolve(atom.config.resourcePath, resolvePath)
if fs.lstatSync(projectPath).isSymbolicLink()
  projectPath = fs.readlinkSync(projectPath)
  if process.platform == 'win32'
    projectPath = atom.config.resourcePath.slice(0, 1).toLowerCase() + projectPath.slice(1)

console.time('fs.existsSync')
for confname in ['config.yaml', 'config.toml', 'docpad.coffee', '_config.yml']
  #todo-me fix load generator ( array configfiles)
  if fs.existsSync path.resolve(projectPath, './' + confname )
    generatorName = switch confname
      when 'config.yaml' then 'hugo'
      when 'config.toml' then 'hugo'
      when 'docpad.coffee' then 'docpad'
      when '_config.yml' then 'hexo'
    break
console.timeEnd('fs.existsSync')

if(generatorName)
  generator = generatorFactory(generatorName)
else
  console.error('statatic generator not found')
  return

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
    theme:
      type: 'string'
      default: generator.config.theme
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
      default: '1313'


  activate: (state) ->
    @generator = generator
    atom.packages.onDidActivateInitialPackages () =>
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

      atom.commands.add 'atom-workspace',
        'docapp:git-sync': =>
          atom.nprogress.start()
          git.sync().then ()->
            atom.nprogress.done()
        'docapp:deploy-ghpages': => @generator.deployGhpages()
        'docapp:preview': => @generator.togglePreview()

      # add git rebase --continue, git push after merge-conflicts detect
      atom.packages.activatePackage('merge-conflicts').then ()=>
        pkg = atom.packages.getActivePackage('merge-conflicts')?.mainModule
        subs = new CompositeDisposable
        subs.add pkg.onDidCompleteConflictResolution (event)=>
          git.gitCmd args: ['rebase', '--continue']
          .then () =>
            @generator.deployGhpages()

      # httpServer.runChildProcess
      #   root: atom.config.get('docapp.outPath')
      #   address: atom.config.get('docapp.serverAddress')
      #   port: atom.config.get('docapp.serverPort')

      httpServer.run
        root: atom.config.get('docapp.outPath')
        host: atom.config.get('docapp.serverHost')
        port: atom.config.get('docapp.serverPort')

#      @generator.runChild()
      @generator.run()

  setMode: (mode)->
    # todo-me refactor setMode -> pathsLength
    pathsLength = atom.project.getPaths().length
    # console.log(pathsLength)
    if pathsLength == 0
      if mode == 'production'
        atom.project.setPaths([atom.config.get 'docapp.srcPath'])
      else if mode == 'dev'
        atom.project.setPaths([atom.config.get 'docapp.rootPath'])
    pathsLength = 1

  deactivate: ->

  serialize: ->
