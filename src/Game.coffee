## Game States
STATE = 
	MENU: 'menu'
	LOADING: 'loading'
	PLAYING: 'playing'
	OVER: 'over'
	PAUSED: 'paused'

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
		@state = STATE.LOADING

		## Initialize Ticker
		@ticker = new Ticker()

		@loadAssets()

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

	setState: (state)->
		@state = state
		@emit 'state', state

	initBoards: ->
		@boards = []
		@boards.push new Board(0)
		new  PlayerController @boards[0]

		if @settings.players == 2
			@boards.push new Board(1)
			@boards[0].opponent = @boards[1]
			@boards[1].opponent = @boards[0]

			if @settings.computer
				new ComputerController @boards[1]
			else
				new PlayerController @boards[1]

		for b in @boards
			b.on 'lose', =>
				console.log @state
				@setState STATE.OVER



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
		@setState STATE.PLAYING

		## emit start 
		@emit 'start'
		

	continue: ->
		@emit 'continue'
		@ticker.start()

		## Change State
		@setState STATE.PLAYING

	stop: ->
		@emit 'stop'
		@ticker.stop()
		delete @boards
		delete @ticker

		## Change State
		@setState STATE.MENU

	pause: ->
		@emit 'pause'
		@ticker.stop()

		## Change State
		@setState STATE.PAUSED

	restart: ->
		@stop()
		@start()


	## Main Game Loop
	loop: ->
		@renderer.render()

	loadAssets: ->
		preload = new createjs.LoadQueue()
		preload.addEventListener "fileload", => @setState STATE.MENU

		preload.loadFile "assets/music/mid.mp3"
		preload.loadFile "assets/music/intro.mp3"
		preload.loadFile "assets/sprites/grey.png"
		preload.loadFile "assets/sprites/purple.png"
		preload.loadFile "assets/sprites/green.png"
		preload.loadFile "assets/sprites/orange.png"
		preload.loadFile "assets/sprites/yellow.png"
		preload.loadFile "assets/sprites/blue.png"


