## Game States
STATE = 
	MENU: '-Menu'
	PLAYING: '-Playing'
	PAUSED: '-Paused'

############################################
## Game Class singleton
############################################

class Game extends Base

	defaults:
		## Player boards
		boards: []

		## Ticker Class
		ticker: {}

		## Rending Class
		renderer: {}


	@settings: 
		players: 1
		music: 1.0
		sound: 1.0
		computer: true


	## Initialize game
	constructor: ()->
		super

		## Set the pointer
		zz.game = this

		## Initialize State
		@state = STATE.MENU

		## Initialize Ticker
		@ticker = new Ticker()


		## Set up main game loop
		@ticker.on 'tick', => @loop()

		## Start the key controller
		@key = new KeyListener

		## start Music controller
		@music = new MusicController

		## Start Sound Controller
		@sound = new SoundController

		## Start Menu Manager
		@manager = new Manager




	initBoards: ->
		@boards = []
		@boards.push new Board(0)
		new PlayerController @boards[0]

		if @settings.players == 2
			@boards.push new Board(1)
			@boards[0].opponent = @boards[1]
			@boards[1].opponent = @boards[0]

			if @settings.computer
				new ComputerController @boards[1]
			else
				new PlayerController @boards[1]



	## Start Ticker and game
	start: (settings)->
		## extend settings
		@settings = $.extend Game.settings, settings, true

		## Initialize Boards
		@initBoards()

		## Start the renderer
		@renderer = new CanvasRenderer this

		## Start board sound controller
		new BoardSoundController(b) for b in @boards
		
		## Start the ticker
		@ticker.start()

		## Change State
		@state = STATE.PLAYING

		## emit start 
		@emit 'start'
		

	continue: ->
		@emit 'continue'
		@ticker.start()
		@state = STATE.PLAYING

	stop: ->
		@emit 'stop'
		@ticker.stop()
		delete @boards
		delete @ticker

		@state = STATE.MENU

	pause: ->
		@emit 'pause'
		@ticker.stop()

		@state = STATE.PAUSED
		console.log @state

	restart: ->
		@stop()
		@start()


	## Main Game Loop
	loop: ->
		@renderer.render()


