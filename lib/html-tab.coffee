{Emitter}   = require 'emissary'
HtmlTabView = require './views/html-tab-view'
htmlTab = null

class HtmlTab
  Emitter.includeInto @
  constructor: (@tabTitle, @url) ->
    @pane = atom.workspace.getActivePane()
  setView: (@htmlTabView) ->
  getClass:     -> HtmlTab
  getViewClass: -> HtmlTabView
  getView:      -> @htmlTabView
  getTitle:     -> @tabTitle
  getUrl:       -> @url
  setUrl: (url) ->
#    if @url != url
    @url = url
    @htmlTabView.page.setAttribute 'src', url
  reload: ->
    @htmlTabView.page.reload()
    # @htmlTabView.page.setAttribute 'src', @url
    atom.nprogress.done()
  destroy: ->
    htmlTab = null

module.exports =
  toggle: (url)->
    if not htmlTab
      if atom.workspace.getActivePane()
        atom.workspace.getActivePane().splitRight {copyActiveItem: false} if atom.config.get('docapp.previewSplitRight')
        htmlTab = new HtmlTab("preview", url)
        atom.workspace.getActivePane().activateItem htmlTab
    else
      htmlTab.pane.destroyItem(htmlTab)

  reload: (timeout) ->
    if htmlTab
      if timeout
        setTimeout () ->
          htmlTab.reload()
        , timeout
      else
        htmlTab.reload()
