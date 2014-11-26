{$, BufferedProcess, Workspace} = require 'atom'

StatusView = require './views/status-view'
path = require('path')
git = require './git'
GeneratorFactory = require('./generators/generator')

# add atom.nprogress
atom.nprogress = require 'nprogress'
atom.nprogress.configure({
  parent : '.tab-bar'
  ,showSpinner: false
})

module.exports =
  config:
    rootPath:
      type: 'string'
      default: path.resolve(atom.config.resourcePath, '../../../project')
    mode:
      type: 'string'
      default: 'production'
    productionPath:
      type: 'string'
      default: path.resolve(atom.config.resourcePath, '../../../project/src')
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

  activate: (state) ->
    @setMode(atom.config.get 'docapp.mode')
    git.checkAvailability()
    @GeneratorDecor = GeneratorFactory atom.config.get('docapp.generator')

    atom.workspaceView.command "docapp:deploy-ghpages", => @GeneratorDecor.deployGhpages()
    atom.workspaceView.command "docapp:preview", =>  @GeneratorDecor.activatePreview()

    atom.on 'merge-conflicts:done', (event) =>
      git.gitCmd args: ['rebase', '--continue']
      .then () =>
        @GeneratorDecor.deployGhpages()

  setMode: (mode)->
    # todo-me refactor setMode -> pathsLength
    pathsLength = atom.project.getPaths().length
    if pathsLength == 0
      if mode == 'production'
        atom.project.setPaths([atom.config.get 'docapp.productionPath'])
      else if mode == 'dev'
        atom.project.setPaths([atom.config.get 'docapp.rootPath'])
    pathsLength = 1

  deactivate: ->

  serialize: ->
