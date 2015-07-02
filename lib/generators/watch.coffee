chokidar = require 'chokidar'
path = require 'path'

module.exports =
  run: (generator)->
    if(!generator or !generator.config?.reloadGlobs)
      return
      debugger;
    projectPath = atom.config.get 'docapp.projectPath'
    
    file = projectPath + path.sep + generator.config.reloadGlobs
    watcher = chokidar.watch file
    log = console.log.bind(console)
    watcher.on 'change', (path) ->
        log('File', path, 'has been changed')
