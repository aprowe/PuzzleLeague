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

    ## Max function
    Array.prototype.max = -> Math.max.apply null, this

    ## Min function
    Array.prototype.min = -> Math.min.apply null, this


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

    	done: (event, args)->
    		return unless @_queue[event]?
    		fn = @_queue[event]
    		@_queue[event] = null
    		fn.call this, args

    	queue: (event, args, fn)->
    		@_queue[event] = fn
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
    	framerate: 60

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
    		, (1000.0/@framerate) if @running

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
    				w = 3
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






    ################################
    ## Rendering Class
    ################################

    class Renderer extends Base

        boardRenderer: ->

        constructor: (@game)->
            super

            @boards = []
            $ =>    
                for b, i in @game.boards
                    @boards.push(new @boardRenderer(b))

        render: -> 
            board.render() for board in @boards

    class BoardRenderer extends Base

        size: 45

        constructor: (@board, @id)->
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

        offset: ()-> 
            @board.counter / @board.speed * @size

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
            $("#puzzle-#{@board.id}").attr width: @board.width * @size , height: @board.height * @size
                
            @stage = new createjs.Stage("puzzle-#{@board.id}")

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

            @board.on 'groupMove', (args)=>
                @groupMoveAnimation (args)

            @board.on 'scoring', (args)=>
                @scoringAnimation(args)

            @board.on 'loss', (args)=>
                @lossAnimation()

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
                .setStrokeStyle 2
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

        renderScore: ->
            if (@board.id == 0)
                $('#score').html(@board.score)

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
            length = 800
            @board.pause()

            each = (b)=>
                b.t = createjs.Tween.get(b.s).to(alpha: 0, length)

            for set in matches
                @hold set
                for block in set
                    each(block)

            setTimeout =>
                @board.continue()
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

        groupMoveAnimation: (args)->
            length = 300

            group = args[0]
            distance = args[1]

            for b in group.blocks
                @initBlock b unless b.s
                @hold(b)
                pos = @toPos(b).y + distance * @size + @offset()
                createjs.Tween.get(b.s).to({y: pos}, length, createjs.Ease.sinIn)

            setTimeout =>
                @release b for b in group.blocks
                @board.done 'groupMove'
            , length


        scoringAnimation: (args)->
            chain = args[0]
            score = args[1]
            set = args[2]

            colors = ["#fff", '#35B13F', '#F7DB01', '#F7040A', '#4AF7ED']

            text = new createjs.Text "#{score} x#{chain}", "20px Montserrat", colors[chain]
            pos = @toPos(set[0])

            text.x = pos.x - @size/2
            text.y = pos.y

            createjs.Tween.get(text).to 
                y: pos.y - @size * 2
                alpha: 0.0
            , 1000
            .call => 
                @stage.removeChild text

            @stage.addChild text

        lossAnimation: ->
            for b in @board.blocks
                @hold b 
                b.color = false
                @stage.removeChild b.s
                @initBlock b


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
                up:    -> @board.moveCursor 0, 1
                down:  -> @board.moveCursor 0, -1
                left:  -> @board.moveCursor -1, 0
                right: -> @board.moveCursor  1, 0
                swap:  -> @board.swap()

        dispatch: (key, args)-> 
            @states[@state][key].call(this, args) if @states[@state][key]?
            zz.game.renderer.render()

    zz.class.eventController = class EventController extends zz.class.controller


        MAPS: [
            {
                37: 'left'
                38: 'up'
                39: 'right'
                40: 'down'
                32: 'swap'
            },
            {
                65: 'left'
                87: 'up'
                68: 'right'
                83: 'down'
                81: 'swap'
            }
        ]



        constructor: (@board)->
            super @board

            @map = @MAPS[@board.id]

            $ => $('body').keydown (e)=>
                # console.log e.which
                key = @map[e.which]
                if key?
                    e.preventDefault(e)
                    @dispatch key





    class SoundController extends Base

    	sounds:
    		click: 'click.wav'
    		swoosh: 'swoosh.mp3'
    		activate: 'activate.wav'

    	events:
    		match: 'activate'
    		cursorMove: 'click'
    		swap: 'swoosh'

    	constructor: (@board)->
    		for key,value of @sounds
    			createjs.Sound.registerSound "assets/sounds/#{value}", key

    		for key, value of @events
    			@board.on key, ((id)->
    				-> createjs.Sound.play id
    			)(value)
    			

    ############################################
    ## Board class does most of the game logic
    ############################################
    zz.class.board = class Board extends zz.class.base

        ## Width of board
        width: 8

        ## Height of board
        height: 10

        ## Speed of the rows raising (frames per row)
        speed: 60*15

        ## Counter to keep track of the rows rising
        counter: 0

        constructor: (@id)->
            super

            @blocks  = []

            @groups  = []

            @score = 0

            @stopped = false

            ## Set up easy grid getter
            Object.defineProperty this, 'grid', get: => @blockArray()

            ## Populate block
            'do' while (=>
                @blocks = []
                for y in [-1..4]    
                    @blocks.push b for b in @createRow y
                @getMatches().length > 0 
            )()


            ## Set Up Cursor
            @cursor = new zz.class.positional
            @cursor.limit [0, @width-2, 0, @height-2]

            ## start game ticker
            zz.game.ticker.on 'tick', =>
                return if @stopped
                @counter++ unless @paused

                if @counter > @speed
                    @counter = 0
                    @pushRow() 

            zz.game.on 'start', =>
                @update()

        checkLoss: ->
            for b in @blocks
                if b.y >= @height-1 and b.active
                    return @lose()

        lose: ->
            @stop()
            @emit 'loss', this
            @pause()


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
                @update()


        moveCursor: (x,y)->
            @emit 'cursorMove'
            @cursor.move(x,y)


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


        scoreMatches: (chain, matches)->
            score = 0 

            for set in matches
                setScore = chain * set.length * 10
                @emit 'scoring', [chain, setScore, set]
                score += setScore

            return score

        addBlocks: (blocks)->
            for b in blocks
                @emit 'add', b
                @blocks.push b

            @update()

        clearBlocks: (blocks)->
            blocks = [blocks] unless blocks.length

            for b in blocks
                @emit 'remove', b
                @blocks.remove(b)

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
            

        update: (chain=1)->
            @_blockArray = null

            @fallDown()
            @checkLoss()

            zz.game.renderer.render() if zz.game.renderer.render?

            matches = @getMatches()

            if matches.length == 0
                @emit 'chainComplete', chain
                return

            for set in matches
                for block in set
                    block.canSwap = false

            score = @scoreMatches chain, matches
            @emit 'score', score
            @score += score

            @queue 'match', matches, =>
                @clearMatches matches
                @update(chain+1)
                @emit 'matchComplete', matches


        #########################
        ## Positional Functions
        #########################
        fallDown: ()->
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
            for group in @groups

                distances = []
                for block in group.bottom
                    d = 1 
                    d++ while not @grid[block.x][block.y - d]? and block.y - d > 0
                    distances.push d

                minDist = distances.min() - 1
                if not group.active
                    @queue 'groupMove', [group, minDist], =>
                        group.moveAll 0,-minDist
                        group.activate()
                        @checkLoss()
                else 
                    group.moveAll 0,-minDist



        pause:   -> @paused = true
        continue: -> @paused = false
        stop: -> @stopped = true


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
    			b.color = false
    			b.active = false

    			@bottom.push b if (j == 0)
    			@blocks.push b

    	moveAll: (x,y)->
    		b.move(x,y) for b in @blocks

    	activate: ()->
    		b.active = true for b in @blocks
    		@active = true
    
    ## Instantiate Game
    new zz.class.game

    return zz
)