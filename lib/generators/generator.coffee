$ = require('atom').$
git = require '../git.coffee'

GeneratorFactory = (name) ->
	Generator = require('./' + name )
	class GeneratorDecorator extends Generator
		@deployGhpages: ->
			git.checkDeployUrl()
			$('.icon-deploy-ghpages').removeClass('icon-mark-github').addClass('loading loading-spinner-tiny').parent().attr("disabled", "disabled")
			super ->
				console.log("ghpages sucses")
				$('.icon-deploy-ghpages').removeClass('loading loading-spinner-tiny').addClass('icon-mark-github').parent().removeAttr("disabled")

	return GeneratorDecorator

module.exports = GeneratorFactory
