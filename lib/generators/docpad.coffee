{BufferedNodeProcess} = require 'atom'
{$} = require process.resourcesPath + '/app/node_modules/space-pen'
{spawn, fork} = require 'child_process'
HtmlTab = require('../html-tab')
path = require('path')

configDefaults =
  rootPath: atom.config.get('docapp.rootPath')

Docpad = require(configDefaults.rootPath+'/node_modules/docpad')

class Generator
  instance = null

  livereloadListener = ()->
    # livereload client init
    socket = new WebSocket('ws://localhost:9778/primus')
    socket.onopen = ()->
      socket.send 'Ping'
      setInterval ()->
        socket.send 'Ping'
      , 3000
    socket.onmessage = (message) ->
      console.log(message)
      iframe = document.getElementById('html-tab-iframe')
      if iframe
        data = JSON.parse(message.data)
        if data.message == 'generateAfter'
          atom.nprogress.start()
          iframe.contentDocument.location.reload(true);
          iframe.onload = ()->
            atom.nprogress.done()
    socket.onclose = (e)->
      console.log(e)


  @run: (callback) ->
    if instance?
      if instance == 'already running'
        setTimeout () =>
          @.run(callback)
        , 1000
      else
        callback()
    else
      instance = 'already running'
      Docpad.createInstance configDefaults, (err, docpadInstance) ->
        return console.log(err.stack)  if err
        docpadInstance.on 'notify', (opt) ->
          console.log(opt.options.title)
        docpadInstance.on 'generateBefore', (opt) ->
          atom.nprogress.start() if $('#html-tab-iframe')[0]
        docpadInstance.action 'generate server watch', (err) ->
#        docpadInstance.action 'server', (err) ->
          console.log(err.stack) if err
          instance = docpadInstance
          livereloadListener()
          callback()

  @runChild: ()->
    console.log(process.env['NODE_ENV'])
    options =
      cwd: atom.config.get('docapp.rootPath')
      detached: true

    args = ['--remote-debugging-port=8258', '--debug-brk']
    stderr = (err) ->
      console.error(err)
    stdout = (data)->
      console.log(data)
    exit = (data)->
      console.log(data)

    child = new BufferedNodeProcess
      command: '/var/www/atom/docapp/lib/generators/docpad-child.js'
      args: args
      options: options
      stdout: stdout
      stderr: stderr
      exit: exit

  @activatePreview: ()->
    filePath = atom.workspaceView.getActiveView()?.editor?.buffer.file?.path
    extname = path.extname filePath
    if filePath and  extname == '.md'
      fileUrl = 'http://0.0.0.0:9778/' + filePath.slice filePath.lastIndexOf('render/')+7, -8
      atom.nprogress.start()
      @run ()->
        atom.workspace.activePane.activateItem new HtmlTab "preview", fileUrl
        atom.nprogress.done()


  @deployGhpages: (callback) ->
    configDefaults.env = 'static'
    Docpad.createInstance configDefaults, (err, docpadInstance) ->
      return console.log(err.stack)  if err
      docpadInstance.on 'notify', (opt) ->
        console.log(opt.options.title)
      docpadInstance.getPlugin('ghpages').deployToGithubPages callback



module.exports = Generator



