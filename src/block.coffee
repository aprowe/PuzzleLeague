############################################
## Block class for each block on the grid
############################################
zz.class.block = class Block extends Positional
	constructor: (@x, @y)->
		super

############################################
##  Colored Block
############################################
zz.class.colorBlock = class ColorBlock extends Block

	colors: 5

	constructor: (@x, @y, @color)->
		super @x, @y
		unless @color?
			@color = Math.round(Math.random()*@colors)%@colors


############################################
##  Big Block
############################################
class bigBlock extends Block

	constructor: (@x, @y, @w, @h)->
		super @x, @y

		@blocks = []

		forall @w, @h, (i,j)->
			@blocks.push new Block(@x + i, @y + j)




