############################################
## Ticker Class to keep a framerate running
############################################
class Ticker extends Base

	## Total frames elapsed
	elapsed: 0

	constructor: (framerate=60)->
		super

		## Frames per second
		@framerate = framerate

		## Is Ticker paused?
		@running = false


	## Start the timer
	start: ->
		return if @running
		@emit 'start'
		@running = true
		@tick()

	## Stop the ticker
	stop: ->
		return unless @running
		@emit 'stop'
		@running = false

	## Emit a frame
	tick: ->	
		@emit 'tick'
		setTimeout =>
			@tick()
			@elapsed++
		, (1000.0/@framerate) if @running
