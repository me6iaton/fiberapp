#$ = require('atom').$  # todo-me  update require $
path = require 'path'
git = require '../git.coffee'
htmlTab = require '../html-tab'
watch = require './watch'

GeneratorFactory = (name) ->
  Generator = require('./' + name )
  class GeneratorDecorator extends Generator
    @run: ()->
      atom.nprogress.start()
      super ->
        watch.run Generator
        atom.nprogress.done()

    @reload: ()->
      atom.nprogress.start()
      super ->
        atom.nprogress.done()

    @kill: ()->

    @togglePreview: ->
      url = "http://#{atom.config.get 'docapp.serverHost'}:#{atom.config.get 'docapp.serverPort'}"
      filePath = atom.views.getView(atom.workspace)?.editor?.buffer.file?.path
      extname = path.extname filePath
      if filePath and  extname == '.md'
        url = url + filePath.replace(atom.config.get('docapp.documentsPath'), '').slice(0, -3)
      htmlTab.toggle url

    @deployGhpages: ->
      atom.nprogress.start()
      git.sync().then ()->
        super ->
          console.log("ghpages sucses")
          atom.nprogress.done()

module.exports = GeneratorFactory
