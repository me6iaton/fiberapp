Docpad = require '/var/www/atom/project/node_modules/docpad'

#console.log(Docpad)

configDefaults =
  rootPath: '/var/www/atom/project/'

process.env['NODE_ENV'] = 'production'
console.log(process.env['NODE_ENV'])

Docpad.createInstance configDefaults, (err, docpadInstance) ->
  return console.log(err.stack)  if err
  docpadInstance.on 'notify', (opt) ->
    console.log(opt.options.title)
  docpadInstance.action 'run', (err) ->
    console.log(err.stack) if err
