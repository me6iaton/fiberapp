{$, BufferedProcess} = require 'atom'
{spawn} = require "child_process"
{allowUnsafeEval} = require 'loophole'
path = require('path')
git = require './git'

module.exports =
	configDefaults:
		rootPath: path.resolve(atom.config.resourcePath, '../../project/')
		environment: 'dev'

	activate: (state) ->
		@switchView()
		@getGenerator()
		git.gitCheckAvailability()
		atom.workspaceView.command "docpad:deploy-ghpages", => @Generator.deployGhpages()

	switchView: ->
		if(atom.config.get('docapp.environment') ? 'dev')
			atom.project.setPaths([atom.config.get('docapp.rootPath')])
		else
			console.log(atom.config.get('docapp.environment'))

	getGenerator: ->
		@Generator = require('./generators/docpad')

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

	deactivate: ->

	serialize: ->
