############################################
## Block class for each block on the grid
############################################
zz.class.block = class Block extends Positional
	constructor: (@x, @y)->

############################################
##  Colored Block
############################################
zz.class.block = class ColorBlock extends Block 
	constructor: (@x, @y, @color)->
		super @x, @y

