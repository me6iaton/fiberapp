#!/usr/bin/env node
{spawn} = require "child_process"
{allowUnsafeEval} = require 'loophole'
Docpad = allowUnsafeEval -> require 'docpad'
#{BufferedNodeProcess} = require 'atom'
module.exports =
	configDefaults:
		rootPath: '/var/www/atom/docpad/'
		pluginPaths: ['/var/www/atom/docpad/']
		packagePath : '/var/www/atom/docapp/package.json'
		configPaths : ['/var/www/atom/docapp/docpad.coffee']
		srcPath: '/var/www/atom/docapp/src/'
		outPath: '/var/www/atom/docapp/out/'
	activate: (state) ->
		atom.workspaceView.command "docpad:generate", => @generate()

	generate: ->
		@createInstance (docpadInstance) ->
			docpadInstance.action "generate", (err, result) ->
				return console.log(err.stack)  if err
				console.log "OK"

	createInstance: (action) ->
		Docpad.createInstance @configDefaults, (err, docpadInstance) ->
			return console.log(err.stack)  if err
			action docpadInstance;

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
