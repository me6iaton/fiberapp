{BufferedNodeProcess} = require 'atom'
htmlTab = require '../html-tab'

projectPath = atom.config.get 'docapp.projectPath'
configDefaults =
  rootPath: projectPath

Docpad = require(projectPath + '/node_modules/docpad')

class Generator
  instance = null

  @config =
    srcPath: './src'
    documentsPath: './src/render'
    outPath: './out'
    theme: ''

  @runChild: (callback)->
    options =
      cwd: atom.config.get 'docapp.projectPath'
      detached: true

    args = ['watch']
    stderr = (err) ->
      console.error(err)
    stdout = (data)->
      console.log(data)
    exit = (data)->
      console.log(data)

    child = new BufferedNodeProcess
      command: '/var/www/atom/docapp/lib/generators/docpad-child.js'
#      command: '/var/www/atom/project/node_modules/docpad/out/bin/docpad.js'
      args: args
      options: options
      stdout: stdout
      stderr: stderr
      exit: exit
    child.onWillThrowError (error) ->
      console.error(error)

  @run: (callback) ->
    if instance?
      if instance == 'already running'
        setTimeout () =>
          @.run(callback)
        , 1000
      else
        callback()
    else
      console.time('docpad-run')
      instance = 'already running'
      Docpad.createInstance configDefaults, (err, docpadInstance) ->
        return console.log(err.stack)  if err
        docpadInstance.on 'notify', (opts) ->
          if opts.options.title == "Website generating..."
            atom.nprogress.start()
          console.log(opts.options.title, opts.message)
        docpadInstance.on 'generateAfter', (opts) ->
          htmlTab.reload()
          atom.nprogress.done()
        docpadInstance.on 'docpadDestroy', (opts) ->
          instance = null
        docpadInstance.action 'generate watch', (err) ->
#        docpadInstance.action 'genetate watch', (err) ->
#        docpadInstance.action 'load ready  watch', (err) ->
          console.log(err.stack) if err
          instance = docpadInstance
          console.timeEnd('docpad-run')
          callback()

  @deployGhpages: (callback) ->
    configDefaults.env = 'static'
    Docpad.createInstance configDefaults, (err, docpadInstance) ->
      return console.log(err.stack)  if err
      docpadInstance.on 'notify', (opt) ->
        console.log(opt.options.title)
      docpadInstance.getPlugin('ghpages').deployToGithubPages callback

module.exports = Generator



