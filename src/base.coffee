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

		@useQueue = true

		for key, value of @defaults
			this[key] = value

	on: (event, fn, state='')->
		return (@on event, fn, s for s in state) if typeof state is 'object' and state.length?
		unless @_events[''+event+state]?
			@_events[''+event+state] = []

		@_events[''+event+state].push fn

	unbind: (event, fn)->
		unless fn?
			@_events[event] = []
		# @TODO

	emit: (event, args, state=false)->
		@emit ''+event+zz.game.state, args, true unless state
		## Call the function on<event>
		return false unless @_events[event]?
		fn.call(this, args) for fn in @_events[event]
		return true

	done: (event, args)->
		return unless @_queue[event]?
		fn = @_queue[event].shift()
		return unless fn?
		fn.call this, args

	queue: (event, args, fn)->
		@_queue[event] = [] unless @_queue[event]?
		@_queue[event].push fn
		@emit event, args

		@done event if not @useQueue

