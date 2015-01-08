{$,View} = require 'space-pen'
{Emitter}   = require 'emissary'

module.exports =
class HtmlTabView extends View

  @content: (@HtmlTab)->
    @div class:'html-tab', tabindex:-1, =>
      @tag 'webview', src: @HtmlTab.getUrl() #

  initialize: (HtmlTab) ->
    HtmlTab.setView @
    @page = @.element.querySelector('webview')
#    observer = new MutationObserver (mutations) ->
#      mutations.forEach (mutation) ->
#        atom.workspace.getActivePane().destroyItem(HtmlTabView.HtmlTab)
#    observer.observe @.element, {attributes: true, attributeFilter: ['style']}
#    @page.onload = () ->
#      HtmlTabView.HtmlTab.url = this.contentWindow.location.href
#  attached: ->
#    @open = true
#  detached: ->
#    @open = false

