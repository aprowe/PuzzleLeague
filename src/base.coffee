##############################
## Base Class with on / emit
##############################
zz.class.base = class Base

	defaults: {}

	constructor: (@_events={})->
		@_events = {
			#name: [fn1, fn2]
		}

		@_queue = {
			#name: [{args: [], fn}, ]
		}

		for key, value of @defaults
			this[key] = value

	on: (event, fn)->
		unless @_events[event]?
			@_events[event] = []

		@_events[event].push fn

	unbind: (event, fn)->
		unless fn?
			@_events[event] = []
		# @TODO

	emit: (event, args)->
		## Call the function on<event>
		this['on'+event].call(this, args) if this['on'+event]?
		return unless @_events[event]?
		fn.call(this, args) for fn in @_events[event]

	done: (event)->
		return unless @_queue[event]?
		@_queue[event][0].call(this, @_queue[event][1])
		delete @_queue[event]

	queue: (event, args, fn)->
		@_queue[event] = [fn, args]
		@emit event, args

