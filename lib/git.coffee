StatusView = require './views/status-view'
childProcess = require 'child_process'
{BufferedProcess} = require 'atom'


_getGitPath = ->
	atom.config.get('docapp.gitPath') ? 'git'


git =
	checkDeployUrl: ->
		unless atom.config.get('docapp.gitSetDeployUrl')
			@gitCmd args: ['remote', 'remove', 'deploy']
			@gitCmd
				args: ['remote', 'add', 'deploy', atom.config.get('docapp.gitDeployUrl')]
				stdout : (data) ->
					console.log(data)
				stderr: (err) ->
					console.error(err)
				exit: () ->
					atom.config.set 'docapp.gitSetDeployUrl', true

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
	gitCmd: ({args, options, stdout, stderr, exit}={}) ->
		command = _getGitPath()
		options ?= {}
		options.cwd ?= atom.config.get('docapp.rootPath')
		stderr ?= (data) -> new StatusView(type: 'alert', message: data.toString())

		if stdout? and not exit?
			c_stdout = stdout
			stdout = (data) ->
				@save ?= ''
				@save += data
			exit = (exit) ->
				c_stdout @save ?= ''
				@save = null

		new BufferedProcess
			command: command
			args: args
			options: options
			stdout: stdout
			stderr: stderr
			exit: exit


module.exports = git
