{BufferedProcess} = require 'atom'
path = require 'path'

class Generator
  hugoProcess = null

  @config =
    srcPath: ''
    documentsPath: './content'
    outPath: './public'
    theme: 'hyde'

  @run: (callback) ->
    projectPath = atom.config.get 'docapp.projectPath'
    command = path.resolve(projectPath, "./bin/hugo-#{process.platform}")
    args = [
      '-s', projectPath ,
      "--theme=#{atom.config.get 'docapp.theme'}" ,
      '-b', "http://localhost:#{atom.config.get 'docapp.serverPort'}/"
      '-w'
    ]
    hugoProcess = new BufferedProcess
      command: command
      args: args
      stdout: (output) ->
        if atom.htmlTab?
          if output.indexOf 'Change detected' is not -1
            atom.htmlTab.reload()
#            atom.nprogress.done()
#        console.log output
      stderr: (err) ->
        console.error err
      exit: (code) ->
        console.log "exited with #{code}"
    hugoProcess.onWillThrowError (error) ->
      console.error(error)
    window.addEventListener 'beforeunload', ->
      hugoProcess.kill()
    callback()

module.exports = Generator
