#!/usr/bin/env node
{$, BufferedProcess} = require 'atom'
StatusView = require './views/status-view'
{spawn} = require "child_process"
#{allowUnsafeEval} = require 'loophole'
#Docpad = allowUnsafeEval -> require 'docpad'
Docpad = require 'docpad'
childProcess = require 'child_process'

module.exports =
	configDefaults:
		rootPath: '/var/www/atom/docpad/'
		pluginPaths: ['/var/www/atom/docpad/']
		packagePath : '/var/www/atom/docapp/package.json'
		configPaths : ['/var/www/atom/docapp/docpad.coffee']
		srcPath: '/var/www/atom/docapp/src/'
		outPath: '/var/www/atom/docapp/out/'

	activate: (state) ->
		atom.workspaceView.command "docpad:deploy-ghpages", => @deployGhpages()
		@gitCheckAvailability()
	generate: ->
		@createInstance (docpadInstance) ->
			docpadInstance.action "generate", (err, result) ->
				return console.log(err.stack)  if err
				console.log "OK"

	deployGhpages: ->
#		process.env['NODE_ENV'] = 'production'
#		process.env['NODE_ENV'] = 'static'
		console.log(process.env['NODE_ENV'])
		$('.icon-deploy-ghpages').removeClass('icon-mark-github').addClass('loading loading-spinner-tiny').parent().attr("disabled", "disabled")
		Docpad.createInstance @configDefaults, (err, docpadInstance) ->
			return console.log(err.stack)  if err
			docpadInstance.on 'notify', (opt) ->
				console.log(opt.options.title)
#			debugger
			docpadInstance.getPlugin('ghpages').deployToGithubPages ->
				console.log("ghpages sucses")
				$('.icon-deploy-ghpages').removeClass('loading loading-spinner-tiny').addClass('icon-mark-github').parent().removeAttr("disabled")
				return

	deployGhpages2: ->
		@createInstance (docpadInstance) ->
			docpadInstance.getPlugin('ghpages').deployToGithubPages ->
				return
			, 'static'

	createInstance: (action, env) ->
		process.env['NODE_ENV'] = env if env
		process.stdout.on "data", (data) ->
			console.log "stdout: " + data
			return
		Docpad.createInstance @configDefaults, (err, docpadInstance) ->
			return console.log(err.stack)  if err
			action docpadInstance;

	gitCheckAvailability: ->
		childProcess.exec("git --version", (error, stdout, stderr) ->
			if error
#				debugger
				console.log error.stack
				console.log "Error code: " + error.code
				console.log "Signal received: " + error.signal
				console.log "Child Process STDERR: " + stderr
				new StatusView type: 'alert', message: stderr.toString()
		)


	generateChildProcess: ->
			options =
				cwd: '/var/www/atom/docapp'
	#			cwd: atom.project.getPath()
			options.env = Object.create(process.env)  unless options.env?
			options.env["ATOM_SHELL_INTERNAL_RUN_AS_NODE"] = 1
			node = (if process.platform is "darwin" then path.resolve(process.resourcesPath, "..", "Frameworks", "Atom Helper.app", "Contents", "MacOS", "Atom Helper") else process.execPath)
			docpadChildProcess = spawn(node, [
				"/var/www/atom/docapp/node_modules/docpad/bin/docpad"
				"generate"
			], options )
			docpadChildProcess.stdout.on "data", (data) ->
				console.log "stdout: " + data
				return
			docpadChildProcess.stderr.on "data", (data) ->
				console.log "stderr: " + data
				return
			docpadChildProcess.on "close", (code) ->
				console.log "child process exited with code " + code
				return

	sleep: (milliSeconds) ->
		startTime = new Date().getTime()
		endTime = startTime + milliSeconds
		while new Date().getTime() < endTime
			startTime++

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
		command = _getGitPath()
		options ?= {}
		options.cwd ?= dir()
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

	deactivate: ->

	serialize: ->
