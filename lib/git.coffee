childProcess = require 'child_process'
{BufferedProcess} = require 'atom'
mergeConflictsPath = atom.packages.resolvePackagePath('merge-conflicts')
MergeState = require mergeConflictsPath + '/lib/merge-state'
{GitBridge} = require mergeConflictsPath + '/lib//git-bridge'

_getGitPath = ->
  atom.config.get('docapp.gitPath') ? 'git'


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
  sync: () ->
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
    .catch (err) =>
      atom.nprogress.done()
      if err
        console.error(err)
        atom.notifications.addError(err)

  #todo-me add use checkDeployUrl
  checkDeployUrl: ->
    unless atom.config.get('docapp.gitSetDeployUrl')
      @gitCmd args: ['remote', 'remove', 'deploy'].then () =>
        @gitCmd args: ['remote', 'add', 'deploy', atom.config.get('docapp.gitDeployUrl')]
      .then () =>
        atom.config.set 'docapp.gitSetDeployUrl', true
    return

  checkAvailability: ->
    childProcess.exec "git --version", (error, stdout, stderr) ->
      if error
        console.log error.stack
        console.log "Error code: " + error.code
        console.log "Signal received: " + error.signal
        console.log "Child Process STDERR: " + stderr
        atom.notifications.addError(stderr.toString())

  # Public: Execute a git command.
  #
  # options - An {Object} with the following keys:
  #   :args    - The {Array} containing the arguments to pass.
  #   :options - The {Object} with options to pass.
  #     :cwd  - Current working directory as {String}.
  #
  # Returns Promise.
  gitCmd: ({args, options, stderr}) ->
    new Promise (resolve, reject) ->
      command = _getGitPath()
      options ?= {}
      options.cwd ?= atom.config.get('docapp.projectPath')

      stderr ?= (data) ->
        @stderrSave ?= ''
        @stderrSave += data + ' <br> '

      stdout = (data) ->
        @stdoutSave ?= ''
        @stdoutSave += data

      exit = ()->
        if @stderrSave
          reject(@stderrSave)
          @stderrSave = null
        else
          resolve @stdoutSave ?= ''
          @stdoutSave = null


      new BufferedProcess
        command: command
        args: args
        options: options
        stdout: stdout
        stderr: stderr
        exit: exit


module.exports = git
