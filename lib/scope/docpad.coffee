#!/usr/bin/env node
Docpad = require 'docpad'
console.log "childProcess yo"
console.log process.version
console.log process.versions
console.log process.cwd()
configDefaults =
	rootPath: '/var/www/atom/docapp'

Docpad.createInstance configDefaults, (err, docpadInstance) ->
	return console.log(err.stack)  if err
	docpadInstance.action "generate", (err, result) ->
		return console.log(err.stack)  if err
		console.log "OK"
