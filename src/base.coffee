##############################
## Base Class with on / emit
##############################
zz.class.base = class Base

	_events: {}

	on: (event, fn)->
		unless @_events[event]?
			@_events[event] = []

		@_events[event].push fn

	unbind: (event, fn)->
		unless fn?
			@_events[event] = []
		# @TODO

	emit: (event, args)->
		return unless @_events[event]?
		fn.apply(this, args) for fn in @_events[event]
