StatusView = require './views/status-view'
childProcess = require 'child_process'
{BufferedProcess} = require 'atom'
mergeConflictsPath = atom.packages.resolvePackagePath('merge-conflicts')
MergeState = require mergeConflictsPath + '/lib/merge-state'
{GitBridge} = require mergeConflictsPath + '/lib//git-bridge'

_getGitPath = ->
  atom.config.get('docapp.gitPath') ? 'git'

sleep = (milliSeconds) ->
  startTime = new Date().getTime()
  endTime = startTime + milliSeconds
  while new Date().getTime() < endTime
    startTime++

mergeConflictsDetect = () ->
  new Promise (resolve, reject) ->
    GitBridge.locateGitAnd (err) ->
      console.error(err) if err?
      MergeState.read (err, state) ->
          console.error(err) if err
          reject(err) if err
          if not state.isEmpty()
            atom.workspaceView.trigger 'merge-conflicts:detect'
            reject()
          else
            resolve()

git =
  sync: (callback) ->
    mergeConflictsDetect().then () =>
      @gitCmd args: ['add', '--all']
    .then () =>
      @gitCmd args: ['status', '-s']
    .then (resolve) =>
      @gitCmd args: ['commit', '-m', resolve]
    .then () =>
      @gitCmd
        args: ['pull', '--rebase', 'origin', 'master']
        stderr: (err) -> console.log(err)
    .then () =>
      mergeConflictsDetect()
    .then () =>
      @gitCmd
        args: ['push', 'origin', 'master']
        stderr: (err) -> console.log(err)
      callback(null, true)
    .catch (err) =>
      console.error(err) if err
      callback(null, false)
    return

  checkDeployUrl: ->
    unless atom.config.get('docapp.gitSetDeployUrl')
      @gitCmd args: ['remote', 'remove', 'deploy']
      @gitCmd
        args: ['remote', 'add', 'deploy', atom.config.get('docapp.gitDeployUrl')]
        exit: () -> atom.config.set 'docapp.gitSetDeployUrl', true
        #	todo-me  remove exit

  checkAvailability: ->
    childProcess.exec "git --version", (error, stdout, stderr) ->
      if error
        console.log error.stack
        console.log "Error code: " + error.code
        console.log "Signal received: " + error.signal
        console.log "Child Process STDERR: " + stderr
        new StatusView type: 'alert', message: stderr.toString()

# Public: Execute a git command.
#
# options - An {Object} with the following keys:
#   :args    - The {Array} containing the arguments to pass.
#   :options - The {Object} with options to pass.
#     :cwd  - Current working directory as {String}.
#   :stdout  - The {Function} to pass the stdout to.
#   :exit    - The {Function} to pass the exit code to.
#
# Returns nothing.
  gitCmd: ({args, options, stdout, stderr}={}) ->
    new Promise (resolve, reject) ->
      command = _getGitPath()
      options ?= {}
      options.cwd ?= atom.config.get('docapp.projectPath')
      stderr ?= (data) -> new StatusView(type: 'alert', message: data.toString())

#			if stdout? and not exit?
#				c_stdout = stdout
#				stdout = (data) ->
#					@save ?= ''
#					@save += data
#				exit = (exit) ->
#					c_stdout @save ?= ''
#					@save = null

      stdout = (data) ->
        @save ?= ''
        @save += data

      exit = ()->
        resolve @save ?= ''
        @save = null


      new BufferedProcess
        command: command
        args: args
        options: options
        stdout: stdout
        stderr: stderr
        exit: exit



module.exports = git
