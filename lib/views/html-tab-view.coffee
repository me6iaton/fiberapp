{$,View} = require 'space-pen'

module.exports =
class HtmlTabView extends View

  @content: (@HtmlTab)->
    @iframe
      class: 'iframe'
      id: 'html-tab-iframe'
#      sandbox: 'allow-scripts'
      allowfullscreen: yes
      src: @HtmlTab.getUrl()
#    @tag 'webview', src: htmlTab.getUrl() #

  initialize: (HtmlTab) ->
    HtmlTab.setView @
    @.element.onload = (e, element, opt) ->
      HtmlTabView.HtmlTab.url = this.contentWindow.location.href

  attached: ->
    @open = true
  detached: ->
    @open = false
