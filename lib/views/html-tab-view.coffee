{View} = require 'space-pen'

module.exports =
class HtmlTabView extends View

  @content: (@HtmlTab)->
    @div class:'html-tab', tabindex:-1, =>  
      @iframe
        class: 'iframe'
        id: 'html-tab-iframe'
        # sandbox:  'allow-forms allow-popups allow-pointer-lock allow-same-origin allow-scripts'
        allowfullscreen: yes
        src: @HtmlTab.getUrl()
#    @tag 'webview', src: htmlTab.getUrl() #

  initialize: (HtmlTab) ->
    HtmlTab.setView @
    @page = @.element.querySelector('iframe')    
    @page.onload = () ->
      HtmlTabView.HtmlTab.url = this.contentWindow.location.href

  attached: ->
    @open = true
  detached: ->
    @open = false
  destroy: -> 
    @detach()  
