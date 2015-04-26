
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


	settings: 
		players: 1


	## Initialize game
	constructor: (settings={})->
		super

		@settings = $.extend @settings, settings, true

		zz.game = this

		@ticker = new zz.class.ticker

		@ticker.on 'tick', => @loop()

		@initBoards @settings.players

		@renderer = new CanvasRenderer(this)
		@controllers = (new EventController(b) for b in @boards)
		@soundsControllers = (new SoundController(b) for b in @boards)

		@musicController = new MusicController this

	initBoards: (players)->
		if players == 1
			@boards = [new Board(0)]
			return

		if players == 2
			@boards = [new Board(0), new Board(1)]
			@boards[0].opponent = @boards[1]
			@boards[1].opponent = @boards[0]


	## Start Ticker and game
	start: ->
		@emit 'start'
		@ticker.start()

	## Main Game Loop
	loop: ->
		@renderer.render()





