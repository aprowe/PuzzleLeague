############################################
## Game Class singleton
############################################
zz.class.game = class Game extends Base

	defaults:
		## Player boards
		boards: []

		## Ticker Class
		ticker: {}

		## Rending Class
		renderer: {}

	## Initialize game
	constructor: ->
		super

		zz.game = this

		@ticker = new zz.class.ticker

		@ticker.on 'tick', =>
			@renderer.render()

		@boards = [
			new Board,
		]

		@renderer = new CanvasRenderer(this)

		@controller = new zz.class.eventController(@boards[0])

	## Start Ticker and game
	start: ->
		@ticker.start()

