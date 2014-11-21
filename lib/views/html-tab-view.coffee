{View} = require 'atom'

module.exports =
class HtmlTabView extends View

  @content: ->
    @iframe
      class: 'iframe'
      outlet: 'iframe'
      id: 'html-tab-iframe'
      name: 'browser-page-disable-x-frame-options'
      sandbox: 'allow-scripts'
      allowfullscreen: yes
#      src: "file:///var/www/atom/project/out/pages/hello.html"
      src: "http://0.0.0.0:9778/pages/hello"
#    @tag 'webview', src: 'http://0.0.0.0:9778/pages/hello' #
