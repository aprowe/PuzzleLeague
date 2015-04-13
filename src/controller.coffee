
#########################
## Controller Class
#########################

zz.class.controller = class Controller extends Base

	board: {}

	@state: null

	constructor: (@board, @state='playing')->
		super

	keys: [
		'up',
		'down',
		'left',
		'right',
		'swap'
	]

	states:
		playing: 
			up:    -> @board.cursor.move 0, 1
			down:  -> @board.cursor.move 0, -1
			left:  -> @board.cursor.move -1, 0
			right: -> @board.cursor.move  1, 0
			swap:  -> @board.swap()

	dispatch: (key, args)-> 
		console.log @board
		@states[@state][key].call(this, args) if @states[@state][key]?
		zz.game.renderer.render()

zz.class.domController = class DomController extends zz.class.controller

	map:
		37: 'left'
		38: 'up'
		39: 'right'
		40: 'down'
		32: 'swap'

	constructor: (@board)->
		super @board

		$ => $('body').keydown (e)=>
			console.log e.which
			key = @map[e.which]
			@dispatch key if key?




