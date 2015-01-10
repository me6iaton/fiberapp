{BufferedProcess} = require 'atom'
path = require 'path'

class Generator
  hugoProcess = null
  projectPath = atom.config.get 'docapp.projectPath'

  @config =
    srcPath: ''
    documentsPath: './content'
    outPath: './public'

  @run: (callback) ->
    command = path.resolve(projectPath, './bin/hugo')
    hugoProcess = new BufferedProcess
      command: command
      args: []
      options: {}
      stdout: (output) ->
        console.log output
      stderr: (err) ->
        console.error err
      exit: (code) ->
        console.log "exited with #{code}"
    hugoProcess.onWillThrowError (error) ->
      console.error(error)
    callback()

module.exports = Generator
