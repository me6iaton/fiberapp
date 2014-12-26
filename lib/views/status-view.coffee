{Subscriber} = require 'emissary'
{$, View} = require 'space-pen'

module.exports =
  class StatusView extends View
    Subscriber.includeInto(this)

    @content = (params) ->
      @div class: 'docapp-modal overlay from-top', =>
        @div class: "#{params.type}", params.message, =>
          @span class: "icon fa fa-close"

    initialize: ->
      @subscribe $(window), 'core:cancel', => @detach()
      @.on 'click', '.fa-close', => @detach()
      atom.workspaceView.append(this)
#      setTimeout => @detach(), 10000

    @detach: (event, element)->
      super
      @unsubscribe()
