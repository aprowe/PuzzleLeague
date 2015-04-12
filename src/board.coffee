############################################
## Board class does most of the game logic
############################################
zz.class.board = class Board extends Base

	## Width of board
	width: 8

	## Height of board
	height: 10

	## Speed of the rows raising (frames per row)
	speed: 20

	## Counter to keep track of the rows rising
	counter: 0

	## Player Cursor
	cursor: {}

	## Rendering class
	renderer: null

	constructor: ()->
		@blocks = []


		c = ['#','@', '%', '*']

		i =0
		for y in [0..@height-1]
			for x in [0..@width-1]
				@blocks.push new ColorBlock(x, y, c[Math.round(Math.random()*100)%4])

		@cursor = new zz.class.positional
		@cursor.limit [0, @width-1, 0, @height]

		Object.defineProperty this, 'grid', get: => @blockArray()

	tick: ->
		@counter++
		@pushRow() if @counter > @speed

	pushRow: ()->
		@emit 'pushRow'
		b.y++ for b in @blocks

	blockArray: ->
		# return @_blockArray if @_blockArray?

		@_blockArray = []
		@_blockArray.fill @width, @height

		for b in @blocks
			@_blockArray[b.x][b.y] = b

		return @_blockArray

	swap: ()->
		b1 = @grid[@cursor.x][@cursor.y]
		b2 = @grid[@cursor.x+1][@cursor.y]

		@emit 'swap', b1, b2

		b1.x = @cursor.x+1 if b1?
		b2.x = @cursor.x if b2?

	match: (blocks)->
		@emit 'match', blocks
		b.remove()
		@blocks.remove b

	#########################
	## Retreival functions
	#########################
	getColumn: (col)->
		col = col.x if col.x?

		return @grid[col]

	getRow: (row)->
		row = row.y if row.y?

		return (@grid[i][row] for i in [0..@width-1])

	getRows: ()->
		@getRow i for i in [0..@height-1]

	getColumns: ()-> @grid

	getAdjacent: (block)->
		blocks = []
		blocks.push @grid[block.x][block.y+1]
		blocks.push @grid[block.x][block.y-1]

		blocks.push @grid[block.x-1][block.y] if @grid[block.x-1]?
		blocks.push @grid[block.x+1][block.y] if @grid[block.x+1]?

		return (b for b in blocks when b?)

	#########################
	## Match Functions
	#########################
	checkRow: (row)->
		sets = []

		b = 0
		while b < row.length-1
			match = []

			while true
				match.push row[b]
				break unless @checkBlocks row[b], row[++b]

			sets.push match if match.length >= 3

		return sets

	checkBlocks: (b1, b2)->
		return false unless b1? and b2?
		b1.color == b2.color

	getMatches: ->
		matches = []
		for row in @getRows()
			matches.push a for a in @checkRow(row)

		for col in @getColumns()
			matches.push a for a in @checkRow(col)

		return matches

	clearBlocks: (blocks)->
		@blocks.remove(b) for b in blocks
		@_blockArray = null

	update: ()->
		@cursor.emit 'check'
		matches = @getMatches()
		@clearBlocks(m) for m in matches
		@fallDown()


	#########################
	## Positional Functions
	#########################
	fallDown: ->
		for col in @getColumns()
			col = col.sort (b1,b2)->
				y1 = if b1? then b1.y else 1000
				y2 = if b2? then b2.y else 1000
				y1 - y2


			for i in [0..col.length-1]
				col[i].y = i if col[i]?

	render: ->
		str = ""

		for row in [@height-1..0]
			str += "\n"
			for col in [0..@width-1]
				if row is @cursor.y and col is @cursor.x
					str +='['
				else
					str+= ' '

				if @grid[col]? and @grid[col][row]?
					str += @grid[col][row].color
				else
					str += '-'

				if row is @cursor.y and col is @cursor.x+1
					str +=']'
				else
					str+= ' '

		return str
