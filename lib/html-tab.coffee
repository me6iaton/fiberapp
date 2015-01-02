{Emitter}   = require 'emissary'
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
        @htmlTabView.page.setAttribute 'src', url
    reload: ->
        debugger
        @htmlTabView.page.setAttribute 'src', @url
        atom.nprogress.done()

