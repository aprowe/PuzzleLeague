###########################
## Positional Class
###########################
zz.class.positional = class Positional extends Base

	constructor: (@x=0, @y=0)->
		super

	## Limit to specific bounds
	limit: (bounds) -> 
		@on 'check', =>
			@x = bounds[0] if @x < bounds[0]
			@x = bounds[1] if @x > bounds[1]
			@y = bounds[2] if @y < bounds[2]
			@y = bounds[3] if @y > bounds[3]


	## Moves and validates
	move: (x,y)->
		## Positional
		if x.x?
			y = x.y
			x = x.x

		# Coordinates
		if x.length?
			x = x[0]
			y = x[1]

		@x += x
		@y += y
		@check()

	## Checks and validates positions
	check: -> 
		@emit 'check'