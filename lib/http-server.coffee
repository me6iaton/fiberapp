{BufferedNodeProcess} = require 'atom'
httpServer = require('../node_modules/http-server/lib/http-server')

module.exports =
  runChildProcess: ({root, host, port})->
    args = [root, '-a', host, '-p', port, '-s', '-c', '1']
    stderr = (err) ->
      console.error(err)
    stdout = (data)->
      console.log(data)
    exit = (data)->
      console.log(data)

    child = new BufferedNodeProcess
      command: process.env.ATOM_HOME + '/packages/docapp/node_modules/http-server/bin/http-server'
      args: args
      stdout: stdout
      stderr: stderr
      exit: exit

    window.addEventListener 'beforeunload', =>
      child.kill()

  run: ({root, host, port})->
    options =
      root: root
      cache: 1
      showDir: true
      autoIndex: true
      ext: 'html'
      logFn: null

    server = httpServer.createServer(options)
    server.listen port, host, ->
      uri = [ "http", "://", host, ":", port ].join("")
