$ = require('atom').$
git = require '../git.coffee'

GeneratorFactory = (name) ->
  Generator = require('./' + name )
  class GeneratorDecor extends Generator

    @deployGhpages: ->
      atom.nprogress.start()
      git.checkDeployUrl()
      git.sync (err, state) ->
        console.log(err) if err
        if state
          super ->
              console.log("ghpages sucses")
              atom.nprogress.done()
        else
          atom.nprogress.done()

  return GeneratorDecor

module.exports = GeneratorFactory
