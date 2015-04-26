zz.modes = {}

zz.modes.single = class SinglePlayer extends Base

	initBoards: ()-> return [new Board(0)]


zz.modes.multi = class MultiPlayer extends Base

	initBoards: ->
		boards = [
			new Board(0),
			new Board(1)
		]

		boards[0].opponent = boards[1]
		boards[1].opponent = boards[0]

		@setUpEvents b for b in boards

		return boards

	setUpEvents: (board)->
		board.on 'score', (score)->
			console.log score
			return if score < 50

			if score >= 50
				w = 2
				h = 2

			if score >= 100
				w = 7
				h = 1

			if score >= 150
				w = 5
				h = 2

			if score >= 200
				w = 7
				h = 2

			if score >= 300
				w = 7 
				h =3

			x = Math.random() * (board.width - w)
			x = Math.round x

			y = board.height-h

			board.opponent.addGroup(new BlockGroup(x,y,w,h))

		# board.on 'chainComplete', (chain)->
		# 	return if chain <= 2

		# 	w = board.width
		# 	h = chain - 1

		# 	x = Math.random() * (board.width - w)
		# 	x = Math.round x

		# 	y = board.height-h

		# 	board.opponent.addGroup(new BlockGroup(x,y,w,h))

		board.on 'loss', ->
			board.opponent.stop()




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
	constructor: (mode='multi')->
		super

		zz.game = this

		@ticker = new zz.class.ticker

		@ticker.on 'tick', => @loop()

		@mode = new zz.modes[mode]

		@boards = @mode.initBoards()

		@renderer = new CanvasRenderer(this)
		@controllers = (new EventController(b) for b in @boards)
		@soundsControllers = (new SoundController(b) for b in @boards)

	initBoards: ->

	## Start Ticker and game
	start: ->
		@emit 'start'
		@ticker.start()

	## Main Game Loop
	loop: ->
		@renderer.render()





