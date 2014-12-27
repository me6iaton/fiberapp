{Emitter}   = require process.resourcesPath + '/app/node_modules/emissary'
HtmlTabView = require './views/html-tab-view'

module.exports =
  class HtmlTab

    Emitter.includeInto @

    constructor: (@tabTitle, @url) ->

    setView: (@htmlTabView) ->
    getClass:     -> HtmlTab
    getViewClass: -> HtmlTabView
    getView:      -> @htmlTabView
    getTitle:     -> @tabTitle
    getUrl:       -> @url
    setUrl: (url) ->
      if @url != url
        @url = url
        @htmlTabView.element.setAttribute 'src', url
    reload: ->
      @htmlTabView.element.setAttribute 'src', @url
#      @htmlTabView.element.contentDocument.location.reload(true);
#      iframe.onload = ()->
#      atom.nprogress.done()
#    destroy: ->

