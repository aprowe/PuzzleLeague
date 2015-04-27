
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
		computer: true


	## Initialize game
	constructor: (settings={})->
		super

		@settings = $.extend @settings, settings, true

		zz.game = this

		@ticker = new Ticker()

		@ticker.on 'tick', => @loop()

		@initBoards @settings.players

		@renderer = new CanvasRenderer(this)

		new EventController @boards[0]

		if @boards.length > 1
			if @settings.computer
				new ComputerController @boards[1]
			else
				new EventController @boards[1] 


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

	stop: ->
		@emit 'stop'
		@ticker.stop()
		delete @boards
		delete @ticker

	pause: ->
		@emit 'pause'
		@ticker.stop()



