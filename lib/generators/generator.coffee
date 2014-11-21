$ = require('atom').$
git = require '../git.coffee'

GeneratorFactory = (name) ->
	Generator = require('./' + name )
	class GeneratorDecor extends Generator

		deployGhpagesDisplayStart = ()->
			$('.icon-deploy-ghpages').removeClass('icon-mark-github').addClass('loading loading-spinner-tiny').parent().attr("disabled", "disabled")

		deployGhpagesDisplayEnd = ()->
			$('.icon-deploy-ghpages').removeClass('loading loading-spinner-tiny').addClass('icon-mark-github').parent().removeAttr("disabled")

		@deployGhpages: ->
			deployGhpagesDisplayStart()
			super ->
				console.log("ghpages sucses")
				deployGhpagesDisplayEnd()
#			git.checkDeployUrl()
#			git.sync (err, state) ->
#				if state
#		  		super ->
#							console.log("ghpages sucses")
#							deployGhpagesDisplayEnd()
#				else
#					deployGhpagesDisplayEnd()

	return GeneratorDecor

module.exports = GeneratorFactory
