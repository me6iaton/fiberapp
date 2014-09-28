Docpad = require "docpad"

configDefaults =
	rootPath: '/var/www/atom/docpad/'
	pluginPaths: ['/var/www/atom/docpad/']
	packagePath : '/var/www/atom/docapp/package.json'
	configPaths : ['/var/www/atom/docapp/docpad.coffee']
	srcPath: '/var/www/atom/docapp/src/'
	outPath: '/var/www/atom/docapp/out/'

process.env['NODE_ENV'] = 'static'

Docpad.createInstance configDefaults, (err, docpadInstance) ->
	return console.log(err.stack)  if err
	docpadInstance.getPlugin('ghpages').deployToGithubPages ->
		return
