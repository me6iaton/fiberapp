{BufferedProcess} = require 'atom'
path = require 'path'
htmlTab = require '../html-tab'

class Generator
  hugoProcess = null

  @config =
    srcPath: ''
    documentsPath: './content'
    outPath: './public'
    theme: 'hyde'
    reloadGlobs: ['config.toml']
    reloadTimeout: 400

  @run: (callback) ->
    projectPath = atom.config.get 'docapp.projectPath'
    command = path.resolve(projectPath, "./bin/hugo-#{process.platform}")
    if process.arch is 'x64' or process.env.hasOwnProperty('PROCESSOR_ARCHITEW6432')
      command = command + "-x64"
    else
      command = command + "-x32"
    if process.platform is "win32"
      command = command + ".exe"
    args = [
      '-s', projectPath ,
      "--theme=#{atom.config.get 'docapp.theme'}" ,
      '-b', "http://localhost:#{atom.config.get 'docapp.serverPort'}/"
      '-w'
    ]
    hugoProcess = new BufferedProcess
      command: command
      args: args
      stdout: (output) =>
        if output.indexOf('Watching for changes') isnt -1
            callback()
        if output.indexOf('Change detected') isnt -1
          atom.nprogress.start()
          setTimeout () =>
            htmlTab.reload()
            atom.nprogress.done()
          , @config.reloadTimeout
      stderr: (err) ->
        console.error err
      exit: (code) ->
        console.log "exited with #{code}"
    hugoProcess.onWillThrowError (error) ->
      console.error(error)
    window.addEventListener 'beforeunload', ->
      hugoProcess.kill()
      if process.platform is "win32"
        ms = 500
        ms += new Date().getTime()
        continue  while new Date() < ms

  @reload: (callback) ->
    hugoProcess.kill()
    @run () ->
      callback()

  @deployGhpages: (callback) ->
    callback()

module.exports = Generator
