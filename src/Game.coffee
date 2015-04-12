############################################
## Game Class singleton
############################################
zz.class.game = class Game extends Base

	## Player boards
	boards: []

	## Ticker Clas
	ticker: {}

	## Initialize game
	constructor: ->
		@ticker = new zz.class.ticker
		@boards = [
			new Board,
			new Board
		]

	## Start Ticker and game
	start: ->
		@ticker.start()

