{$,View} = require 'space-pen'

module.exports =
class HtmlTabView extends View

  @content: (htmlTab)->
    @iframe
      class: 'iframe'
      id: 'html-tab-iframe'
#      sandbox: 'allow-scripts'
      allowfullscreen: yes
      src: htmlTab.getUrl()
#    @tag 'webview', src: htmlTab.getUrl() #

  initialize: (htmlTab) ->
    htmlTab.setView @
  attached: ->
    @open = true
  detached: ->
    @open = false
