#$ = require('atom').$  # todo-me  update require $
path = require('path')
git = require '../git.coffee'
HtmlTab = require('../html-tab')

GeneratorFactory = (name) ->
  Generator = require('./' + name )
  class GeneratorDecorator extends Generator
    @run: ()->
      atom.nprogress.start()
      super ->
        atom.nprogress.done()

    @kill: ()->

    @activatePreview: ->
      filePath = atom.workspaceView.getActiveView()?.editor?.buffer.file?.path
      extname = path.extname filePath
      if filePath and  extname == '.md'
        atom.nprogress.start()
        urlPath = filePath.replace(atom.config.get('docapp.documentsPath'), '').slice(0, -3)
        fileUrl = "http://#{atom.config.get 'docapp.serverAddress'}:#{atom.config.get 'docapp.serverPort'}#{urlPath}"
        if @HtmlTab?
          @HtmlTab.setUrl fileUrl
        else
          @HtmlTab = new HtmlTab("preview", fileUrl)
        super () =>
          atom.workspace.activePane.activateItem @HtmlTab
          atom.nprogress.done()

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
