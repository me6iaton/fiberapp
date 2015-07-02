chokidar = require 'chokidar'
path = require 'path'
watcher = null

module.exports =
  run: (generator)->
    if(!generator or !generator.config?.reloadGlobs or watcher)
      return
    projectPath = atom.config.get 'docapp.projectPath'
    reloadGlobs = generator.config.reloadGlobs
    if reloadGlobs instanceof Array
      reloadGlobs = reloadGlobs.map (currentValue) ->
        currentValue = projectPath + path.sep + currentValue
    else
      reloadGlobs = projectPath + path.sep + reloadGlobs

    watcher = chokidar.watch reloadGlobs
    log = console.log.bind(console)
    watcher.on 'change', (path) ->
        log('File', path, 'has been changed')
        generator.reload()
