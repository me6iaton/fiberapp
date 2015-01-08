#$ = require('atom').$  # todo-me  update require $
path = require('path')
git = require '../git.coffee'
htmlTab = require('../html-tab')

GeneratorFactory = (name) ->
  Generator = require('./' + name )
  class GeneratorDecorator extends Generator
    @run: ()->
      atom.nprogress.start()
      super ->
        atom.nprogress.done()

    @kill: ()->

    @togglePreview: ->
      url = "http://#{atom.config.get 'docapp.serverHost'}:#{atom.config.get 'docapp.serverPort'}"
      filePath = atom.workspaceView.getActiveView()?.editor?.buffer.file?.path
      extname = path.extname filePath
      if filePath and  extname == '.md'
        url = url + filePath.replace(atom.config.get('docapp.documentsPath'), '').slice(0, -3)
      htmlTab.toggle url

    @deployGhpages: ->
      atom.nprogress.start()
      git.checkDeployUrl()
      git.sync (err, state) ->
        console.log(err) if err
        if state
          super ->
              console.log("ghpages sucses")
              atom.nprogress.done()
        else
          atom.nprogress.done()

module.exports = GeneratorFactory
