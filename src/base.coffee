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
		console.log(@_events)
		unless @_events[event]?
			@_events[event] = []

		@_events[event].push fn

	unbind: (event, fn)->
		unless fn?
			@_events[event] = []
		# @TODO

	emit: (event, args)->
		## Call the function on<event>
		this['on'+event].apply(this, args) if this['on'+event]?
		return unless @_events[event]?
		fn.apply(this, args) for fn in @_events[event]

	done: (event)->
		return unless @_queue[event]?
		@_queue[event][0].apply(this, @_queue[event][1])
		delete @_queue[event]

	queue: (event, args, fn)->
		@emit event, args
		@_queue[event] = [fn, args]
