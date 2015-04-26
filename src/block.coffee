############################################
## Block class for each block on the grid
############################################
zz.class.block = class Block extends Positional

	constructor: (@x, @y)->
		@canSwap = true
		@color = false
		@active = true
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
		@active = false

		forall @w, @h, (i,j)=>
			b = new Block(@x + i, @y + j)

			b.group = this
			b.canSwap = false
			b.color = 0
			b.active = false

			@bottom.push b if (j == 0)
			@blocks.push b

	moveAll: (x,y)->
		b.move(x,y) for b in @blocks

	activate: ()->
		b.active = true for b in @blocks
		@active = true