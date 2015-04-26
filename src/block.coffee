############################################
## Block class for each block on the grid
############################################
zz.class.block = class Block extends Positional

	colors: 5

	constructor: (@x, @y)->
		@canSwap = true
		@canLose = true
		@color = @randomColor()
		super

	randomColor: ->
		Math.round(Math.random()*@colors)%@colors + 1


class GrayBlock extends Block

	constructor: (@x, @y, @group)->
		super @x,@y

		@color = 0
		@canSwap = 0

		# Block must fall down before 
		# it can be counted against lost
		@canLose = 0 

############################################
##  Big Block
############################################
class BlockGroup extends Positional

	constructor: (@x, @y, @w, @h)->
		super @x, @y

		@canLose = false

		## Array of blocks
		@blocks = []

		## Array of bottom blocck
		@bottom = []

		forall @w, @h, (i,j)=>
			b = new GrayBlock @x + i, @y + j this

			@bottom.push b if (j == 0)
			@blocks.push b

	moveAll: (x,y)->
		b.move(x,y) for b in @blocks

	activate: ()->
		b.canLose = true for b in @blocks
		@canLose = true