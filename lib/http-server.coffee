{BufferedNodeProcess} = require 'atom'
{$} = require 'space-pen'
child = null

module.exports =
  run: ({path, address, port})->
#    args = [path, '-p', port, '-s']
    args = [path, '-a', address, '-p', port, '-s']
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

    $(window).on 'beforeunload', =>
      child.kill()
