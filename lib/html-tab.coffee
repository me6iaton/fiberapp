{Emitter}   = require process.resourcesPath + '/app/node_modules/emissary'
HtmlTabView = require './views/html-tab-view'

module.exports =
  class HtmlTab

    # This may appear to not be used but the tab opener code requires it
    Emitter.includeInto @

    constructor: (@tabTitle, @url) ->

    setView: (@htmlTabView) ->
    getClass:     -> HtmlTab
    getViewClass: -> HtmlTabView
    getView:      -> @htmlTabView
    getTitle:     -> @tabTitle
    getUrl:       -> @url
#    destroy: ->
