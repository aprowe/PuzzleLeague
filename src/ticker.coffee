############################################
## Ticker Class to keep a framerate running
############################################
zz.class.ticker = class Ticker extends Base

	## Frames per second
	framerate: 60

	## Is Ticker paused?
	running: false

	## Total frames elapsed
	elapsed: 0

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
