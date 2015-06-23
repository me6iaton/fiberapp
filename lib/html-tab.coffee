{Emitter}   = require 'emissary'
HtmlTabView = require './views/html-tab-view'

class HtmlTab
  Emitter.includeInto @
  constructor: (@tabTitle, @url) ->
    atom.htmlTab = @
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
    delete atom.htmlTab

module.exports =
  toggle: (url)->
    if not atom.htmlTab?
      # console.log atom.workspace.getActivePane()
      if atom.workspace.getActivePane()
        atom.workspace.getActivePane().splitRight {copyActiveItem: false} if atom.config.get('docapp.previewSplitRight')
        atom.workspace.getActivePane().activateItem new HtmlTab("preview", url)
    else
      atom.htmlTab.pane.destroyItem(atom.htmlTab)
#      atom.htmlTab.setUrl(url)
