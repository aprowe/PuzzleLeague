# A genetic algorithm calculator with ANN
# Copyright (c) 2015 Alex Rowe <aprowe@ucsc.edu>
# Licensed MIT

root = if window? then window else this

((factory)-> 

    # Node
    if typeof exports == 'object'
        module.exports = factory.call root 

    # AMD
    else if typeof define == 'function' and define.amd 
        define -> factory.call root

    # Browser globals (root is window)
    else 
        root.zz = factory.call root

)(->
    ################
    ## Main Object
    ################
    zz = {}

    ## Object of classes
    zz.class = {}

    ########################
    ## Array Overrides
    ########################

    ## Function to remove an item from an array
    Array.prototype.remove = (item)->
        if this.indexOf(item) > -1
            this.splice this.indexOf(item), 1
        return item

    ## Function to fill an array with undefined indexes
    Array.prototype.fill = (w,h)->
        this[i] = [] for i in [0..w-1]
        this[i][h] = undefined for i in [0..w-1]


    forall = (w,h,fn)->
        arr = []
        for i in [0..w-1]
            for j in [0..h-1]
                arr.push fn(i,j)

        return arr
    ##############################
    ## Base Class with on / emit
    ##############################
    zz.class.base = class Base

    	defaults: {}

    	constructor: (@_events={})->
    		@_events = {
    			#name: [fn1, fn2]
    		}

    		@_queue = {
    			#name: [{args: [], fn}, ]
    		}

    		for key, value of @defaults
    			this[key] = value

    	on: (event, fn)->
    		unless @_events[event]?
    			@_events[event] = []

    		@_events[event].push fn

    	unbind: (event, fn)->
    		unless fn?
    			@_events[event] = []
    		# @TODO

    	emit: (event, args)->
    		## Call the function on<event>
    		this['on'+event].call(this, args) if this['on'+event]?
    		return unless @_events[event]?
    		fn.call(this, args) for fn in @_events[event]

    	done: (event)->
    		return unless @_queue[event]?
    		@_queue[event][0].call(this, @_queue[event][1])
    		delete @_queue[event]

    	queue: (event, args, fn)->
    		@_queue[event] = [fn, args]
    		@emit event, args


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
    ############################################
    ## Ticker Class to keep a framerate running
    ############################################
    zz.class.ticker = class Ticker extends Base

    	## Frames per second
    	framerate: 25

    	## Is Ticker paused?
    	running: false

    	## Total frames elapsed
    	elapsed: 0

    	## Start the timer
    	start: ->
    		return if @running
    		@emit 'start'
    		@running = true
    		@tick()

    	## Stop the ticker
    	stop: ->
    		return unless @running
    		@emit 'stop'
    		@running = false

    	## Emit a frame
    	tick: ->	
    		@emit 'tick'
    		setTimeout =>
    			@tick()
    			@elapsed++
    		, (1000/@framerate) if @running

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
    	constructor: ->
    		super

    		zz.game = this

    		@ticker = new zz.class.ticker

    		@ticker.on 'tick', =>
    			@renderer.render()

    		@boards = [
    			new Board,
    		]

    		@renderer = new CanvasRenderer(this)

    		@controller = new zz.class.eventController(@boards[0])

    	## Start Ticker and game
    	start: ->
    		@ticker.start()


    ################################
    ## Rendering Class
    ################################

    class Renderer extends Base

        boardRenderer: ->

        constructor: (@game)->
            super

            @boards = []
            $ =>    
                for b in @game.boards
                    @boards.push(new @boardRenderer b)

        render: -> 
            board.render() for board in @boards

    class BoardRenderer extends Base



        constructor: (@board)->
            super
            @init()
            @initBackground()
            @initBlock b for b in @board.blocks
            @initCursor @board.cursor
            @initScore()


        init: ()->
        initBackground: ()->
        initBlock: (block)->
        initCursor: (cursor)->
        initScore: ()->


        render: ()->
            @renderBlock b for b in @board.blocks
            @renderCursor @board.cursor
            @renderScore()

        renderBackground: ->
        renderBlock:  (block)->
        renderCursor: (cursor)->
        renderScore:  ()->

        # @animate: (event, animation)->
        #     @board.on 'event', (args)->
        #         callback = animation()
        #         setTimeout callback, 
                

        size: 50 

        offset: ()-> @board.counter / @board.speed * @size

        toPos: (pos)->
            x: pos.x * @size
            y: (@board.height - pos.y - 1) * @size



    # class DomRenderer extends zz.class.renderer

    #     blockSize: 50

    #     offset: 0

    #     colors: [
    #         'red', 
    #         'blue',
    #         'green', 
    #         'yellow',
    #         'purple',
    #     ]


    #     constructor: (@game)->
    #         throw 'JQuery Not found' unless $?

    #         @board = @game.boards[0]
    #         $ => @setUpElement()

    #         @board.on 'swap', (b1, b2)=>
    #             b1.swapping =  1 if b1?
    #             b2.swapping = -1 if b2?

    #         @board.on 'match', (matches)=>
    #             for sets in matches
    #                 for block in sets
    #                     block.matched = 0

    #     setUpElement: ()->
    #         @element = $ '#puzzle'
    #         @element.width  @board.width  * @blockSize
    #         @element.height @board.height * @blockSize

    #     render: ()-> 
    #         @offset = 1.0*@board.counter/@board.speed * @blockSize

    #         @renderBoard @board
    #         @renderBlock b for b in @board.blocks
    #         @renderCursor @board.cursor
    #         @renderScore()

    #     renderBoard: (board)->
    #         @element.find('.block').remove()

    #     renderCursor: (cursor) ->
    #         @element.find('.cursor').remove()
    #         el = $ '<div></div>', class: 'cursor'
    #             .appendTo @element

    #         el.width @blockSize * 2
    #         el.height @blockSize * 1

    #         el.css
    #             bottom: cursor.y * @blockSize + @offset
    #             left: cursor.x * @blockSize

    #     renderBlock: (block)->
    #         return unless block?
    #         offset = 0 
    #         if block.swapping?
    #             offset = block.swapping+=25 if block.swapping > 0
    #             offset = block.swapping-=25 if block.swapping < 0

    #             if block.swapping <= -@blockSize or block.swapping >= @blockSize
    #                 @board.done 'swap'
    #                 delete block.swapping
    #                 offset = 0

    #         el = $ '<div></div>', 
    #             class: 'block'
    #         .appendTo @element

    #         if block.matched?
    #             el.addClass('matched')
    #             block.matched++

    #             if block.matched > 10
    #                 delete block.matched
    #                 @board.done 'match'

    #         el.width @blockSize
    #         el.height @blockSize

    #         if block.y < 0 
    #             el.css opacity: 0.5

    #         el.css 
    #             bottom: block.y * @blockSize + @offset
    #             left:   block.x * @blockSize + offset
    #             background: @colors[block.color]


    #     renderScore: ->
    #         $ '#score' 
    #             .html @board.score





    class CanvasBoardRenderer extends BoardRenderer

        colors: [
            'grey', 
            'blue',
            'green', 
            'yellow',
            'orange',
            'red',
        ]

        init: ()->
            $('#puzzle').attr width: @board.width * @size , height: @board.height * @size
            
            @stage = new createjs.Stage('puzzle')

            ## Set up animations
            # @animation 'swap', @swapAnimation, 100
            @board.on 'swap', (blocks)=>
                @swapAnimation blocks

            @board.on 'match', (matches)=>
                @matchAnimation matches

            @board.on 'remove', (block)=>
                @stage.removeChild block.s 

            @board.on 'dispersal', (args)=>
                @dispersalAnimation (args)

        initBackground: ()->
            @background = new createjs.Shape()
            @background.graphics
                .beginFill 'black'
                .drawRect 0, 0, @size * @board.width, @size * @board.height

            @stage.addChild @background

        initBlock: (block)->
            block.s = new createjs.Shape()

            @release block

            color = if block.color then @colors[block.color] else 'gray'

            block.s.graphics
                .beginFill color
                .drawRect 0, 0, @size, @size

            @renderBlock block

            @stage.addChild block.s


        initCursor: (cursor)->
            cursor.s = new createjs.Shape()

            cursor.s.graphics
                .beginStroke 'white'
                .drawRect 0, 0, @size*2, @size

            @stage.addChild cursor.s

        render: ()->
            super
            @stage.update()

        renderCursor: (cursor)->
            pos = @toPos cursor
            cursor.s.x = pos.x
            cursor.s.y = pos.y - @offset()

        renderBlock: (b)->
            @initBlock b unless b.s?

            return unless b._stop? and not b._stop

            pos = @toPos b
            b.s.x = pos.x
            b.s.y = pos.y - @offset()

        swapAnimation: (blocks)->
            length = 100

            b1 = blocks[0]
            b2 = blocks[1]
            @hold b1,b2

            ease = createjs.Ease.linear

            if (b1? and not b2?) or (b2? and not b1?)
                length += 100
                ease = createjs.Ease.quadOut

            t1 = createjs.Tween.get(b1.s).to(x: b1.s.x+@size, length, ease) if b1?
            t2 = createjs.Tween.get(b2.s).to(x: b2.s.x-@size, length, ease) if b2?   

            setTimeout =>
                @release b1, b2
                @board.done 'swap'
            , length


        matchAnimation: (matches)->
            length = 200

            each = (b)=>
                b.t = createjs.Tween.get(b.s).to(alpha: 0, length)

            for set in matches
                @hold set
                for block in set
                    each(block)


            setTimeout =>
                @release set for set in matches
                @board.done 'match'
            , length

        dispersalAnimation: (args)->

            oldBlocks = args.oldBlocks
            newBlocks = args.newBlocks

            perLength = 100
            length = perLength * (newBlocks.length+1)

            @board.pause()

            @hold oldBlocks

            for b, i in newBlocks
                fn = ((b1, b2)=>
                    return => 
                        @initBlock b1
                        @stage.removeChild b2
                )(b, oldBlocks[i])

                setTimeout fn, i*perLength


            #     setTimeout =>
            #         @initBlock newBlocks[i]
            #         @stage.removeChild newBlocks[i].s
            #     , i * 100

            # for b, i in oldBlocks.blocks
                # @stage.removeChild b.s
                # b.s = newBlocks[i].s
                # b.s.graphics.beginFill(/'red').drawRect(20,20)

            setTimeout =>
                @board.done 'dispersal'
                @board.continue()
            ,length


        hold: (obj)-> 
            return (@hold o for o in arguments) if arguments.length > 1?
            return unless obj?
            return (@hold o for o in obj) if obj.length? and obj.length > 1?
            obj._stop = true

        release: (obj)-> 
            return (@release o for o in arguments) if arguments.length > 1?
            return unless obj?
            return (@release o for o in obj) if obj.length? and obj.length > 1?
            obj._stop = false

            
    class CanvasRenderer extends Renderer

        boardRenderer: CanvasBoardRenderer


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
    		@states[@state][key].call(this, args) if @states[@state][key]?
    		zz.game.renderer.render()

    zz.class.eventController = class EventController extends zz.class.controller

    	map:
    		37: 'left'
    		38: 'up'
    		39: 'right'
    		40: 'down'
    		32: 'swap'

    	constructor: (@board)->
    		super @board

    		$ => $('body').keydown (e)=>
    			# console.log e.which
    			key = @map[e.which]
    			if key?
    				e.preventDefault(e)
    				@dispatch key





    ############################################
    ## Board class does most of the game logic
    ############################################
    zz.class.board = class Board extends zz.class.base

        defaults: 
            ## Width of board
            width: 8

            ## Height of board
            height: 10

            ## Speed of the rows raising (frames per row)
            speed: 200

            ## Counter to keep track of the rows rising
            counter: 0

            ## Player Cursor
            cursor: {}

            score: 0

            ## Block Array
            blocks: []

            groups: []


        constructor: ()->
            super

            ## Set up easy grid getter
            Object.defineProperty this, 'grid', get: => @blockArray()

            ## Populate block
            for y in [-1..4]    
                @blocks.push b for b in @createRow y


            @addGroup(new BlockGroup(1,7,3,3))

            ## Set Up Cursor
            @cursor = new zz.class.positional
            @cursor.limit [0, @width-2, 0, @height-2]


            ## start game ticker
            zz.game.ticker.on 'tick', =>
                @counter++ unless @paused

                if @counter > @speed
                    @counter = 0
                    @pushRow() 

                # if Math.random() < 0.1 and @groups.length == 0 
                    # @addGroup(new BlockGroup(1,7,3,3))

                @update()

        createRow: (y)-> 
            (new ColorBlock(x, y) for x in [0..@width-1])


        pushRow: ()->
            b.y++ for b in @blocks
            @cursor.move 0, 1

            @blocks.push b for b in @createRow -1

            @update()

        addGroup: (group)->
            @groups.push group
            @addBlocks group.blocks

        blockArray: ->
            # return @_blockArray if @_blockArray?

            @_blockArray = []
            @_blockArray.fill @width, @height

            for b in @blocks
                @_blockArray[b.x][b.y] = b if b.y >= 0

            return @_blockArray

        swap: ()->
            b1 = @grid[@cursor.x][@cursor.y]
            b2 = @grid[@cursor.x+1][@cursor.y]

            x = @cursor.x

            return if b1? and not b1.canSwap
            return if b2? and not b2.canSwap

            @queue 'swap', [b1,b2], =>
                b1.x = x+1 if b1?
                b2.x = x if b2?



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
            grid = @grid

            blocks = []
            blocks.push grid[block.x][block.y+1]
            blocks.push grid[block.x][block.y-1]

            blocks.push grid[block.x-1][block.y] if grid[block.x-1]?
            blocks.push grid[block.x+1][block.y] if grid[block.x+1]?

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
            return false unless b1.color and b2.color
            b1.color == b2.color

        getMatches: ->
            matches = []
            firstRow = false
            for row in @getRows()
                matches.push a for a in @checkRow(row)

            for col in @getColumns()
                matches.push a for a in @checkRow(col)

            return matches

        clearMatches: (matches)->
            for m in matches
                @clearBlocks m 
                @checkDisperse m

            @score += matches.length

        addBlocks: (blocks)->
            for b in blocks
                @emit 'add', b
                @blocks.push b

            @_blockArray = null

        clearBlocks: (blocks)->
            blocks = [blocks] unless blocks.length

            for b in blocks
                @emit 'remove', b
                @blocks.remove(b)

            @_blockArray = null

        checkDisperse: (blocks)->
            for block in blocks
                for b in @getAdjacent block
                    return @disperseGroup b.group  if b.group?

        disperseGroup: (group)->
            return unless @groups.indexOf group > -1
            @groups.remove group

            newBlocks = (new ColorBlock(block.x, block.y) for block in group.blocks)

            @queue 'dispersal', {oldBlocks: group.blocks, newBlocks: newBlocks}, ()=>
                @addBlocks newBlocks
                @clearBlocks group.blocks
                



        update: ()->
            @fallDown() 
            zz.game.renderer.render()
            matches = @getMatches()
            return unless matches.length > 0 
            @queue 'match', matches, =>
                @clearMatches matches
                @update()


        #########################
        ## Positional Functions
        #########################
        fallDown: ->
            ## Fall Down Indivitual Blocks
            grid = @grid
            for i in [0..grid.length-1]
                for j in [1..grid[i].length-1]

                    continue unless grid[i][j]

                    continue if grid[i][j].group?

                    y = j
                    while grid[i][y]? and not grid[i][y-1]? and y > 0
                        grid[i][y-1] = grid[i][y]
                        grid[i][y-1].y--
                        grid[i][y] = null
                        y--

            ## Fall Down Groups
            grid = @grid
            for group in @groups

                falling = true
                for block in group.bottom
                    if grid[block.x][block.y-1]?
                        falling = false
                        break

                group.moveAll(0,-1) if falling

        pause:   -> @paused = true
        continue: -> @paused = false

        # fallDown: ->
        #     for col in @getColumns()
        #         col = col.sort (b1,b2)->
        #             y1 = if b1? then b1.y else 1000
        #             y2 = if b2? then b2.y else 1000
        #             y1 - y2


        #         for i in [0..col.length-1]
        #             col[i].y = i if col[i]?


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
    
    ## Instantiate Game
    new zz.class.game

    return zz
)