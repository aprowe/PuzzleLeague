############################################
## Block class for each block on the grid
############################################
zz.class.block = class Block extends Positional

	constructor: (@x, @y)->
		@canSwap = true
		@color = false
		super

############################################
##  Colored Block
############################################
zz.class.colorBlock = class ColorBlock extends Block

	colors: 5

	constructor: (@x, @y, @color)->
		super @x, @y
		@color = Math.round(Math.random()*@colors)%@colors + 1


############################################
##  Big Block
############################################
class BlockGroup extends Positional

	constructor: (@x, @y, @w, @h)->
		super @x, @y
		@blocks = []
		@bottom = []

		forall @w, @h, (i,j)=>
			b = new Block(@x + i, @y + j)

			b.group = this
			b.canSwap = false
			b.color = false

			@bottom.push b if (j == 0)
			@blocks.push b

	moveAll: (x,y)->
		b.move(x,y) for b in @blocks