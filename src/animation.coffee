
class Animation

	constructor: (@run, @length)->
		@callback = ->
		@length = 0
		@run: ->

