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
    				w = 2
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








    ## Class to Manage Menu Screens
    class Manager

        constructor: ()->
            @menus = {}

            @actions =
                startSingle: =>
                    @startGame('single')
                vsFriend: => 
                    @startGame('multi')

            $ => @setUpMenu()

        setUpMenu: ->
            that = this

            @menus = $('.menu')
            @menus.find('div').click ->

                id = $(this).data 'menu'
                that.showMenu id if id? 
                    
                action = $(this).data 'action'
                that.actions[action].call(that) if action?

        showMenu: (id)->
            @menus.hide()
            $(".menu##{id}").show()

        startGame: (mode)->
            $('.main').hide()
            @game = new Game(mode)
            @game.start()
        
        endGame: ->
            $('.main').show()
            @game.end()

    ################################
    ## Rendering Class
    ################################

    class Renderer extends Base

        boardRenderer: ->

        constructor: (@game)->
            super

            $('.puzzle').hide()

            @boards = []
            $ =>    
                for b, i in @game.boards
                    @boards.push(new @boardRenderer(b))

        render: -> 
            board.render() for board in @boards

    class BoardRenderer extends Base

        size: 34

        constructor: (@board)->
            super
            @init()
            @initBackground()
            @initCursor @board.cursor
            @initBlock b for b in @board.blocks
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
            $("#puzzle-#{@board.id}").attr
                width: @board.width * @size
                height: @board.height * @size
            .show()

            @stage = new createjs.Stage("puzzle-#{@board.id}")

            @loadSprites()
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
                # .beginFill 'black'
                .drawRect 0, 0, @size * @board.width, @size * @board.height

            @stage.addChildAt @background, 0 

        initBlock: (block)->
            block.s = new createjs.Sprite @sprites[block.color], 'still'
            @release block

            # color = if block.color then @colors[block.color] else 'gray'

            # block.s.graphics
                # .beginFill color
                # .drawRect 0, 0, @size, @size

            @renderBlock block

            @stage.addChildAt block.s, @stage.children.length - 1, 


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
            b.s.x = pos.x + 1 
            b.s.y = pos.y - @offset() + 1

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
            length = 750
            @board.pause()
            @render()

            each = (b)=>
                b.t = createjs.Tween.get(b.s).wait(length*.75).to(alpha: 0, length*.25)
                b.s.gotoAndPlay 'matching'

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
            chain = args[0]-1
            score = args[1]
            set = args[2]

            colors = ["#fff", '#35B13F', '#F7DB01', '#F7040A', '#4AF7ED']

            text = new createjs.Text "#{score}", "20px Montserrat", colors[chain]
            pos = @toPos(set[0])

            text.x = pos.x + @size/2
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
                b.color = 0
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

        loadSprites: ()->
            @sprites = []
            data = 
                frames:
                    width: 32
                    height: 32

                animations:
                    still: 5
                    matching: 
                        frames: (i for i in [5..1]).concat (i for i in [1..5])
                        # next: 'matched'
                        speed: 0.75
                    matched: 0

            data.animations.still = 0 
            data.images = ["assets/sprites/grey.png"]
            @sprites.push new createjs.SpriteSheet data

            data.animations.still = 5
            data.images = ["assets/sprites/green.png"]
            @sprites.push new createjs.SpriteSheet data

            data.images = ["assets/sprites/orange.png"]
            @sprites.push new createjs.SpriteSheet data

            data.images = ["assets/sprites/yellow.png"]
            @sprites.push new createjs.SpriteSheet data

            data.images = ["assets/sprites/blue.png"]
            @sprites.push new createjs.SpriteSheet data

            data.images = ["assets/sprites/purple.png"]
            @sprites.push new createjs.SpriteSheet data

            
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
            'swap',
            'advance'
        ]

        states:
            playing: 
                up:    -> @board.moveCursor 0, 1
                down:  -> @board.moveCursor 0, -1
                left:  -> @board.moveCursor -1, 0
                right: -> @board.moveCursor  1, 0
                swap:  -> @board.swap()
                advance:  -> @board.counter+=30

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
                13: 'advance'
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

            ## Array of blocks
            @blocks  = []

            ## Array of groups
            @groups  = []

            ## initial score
            @score = 0

            ## Set up easy grid getter
            Object.defineProperty this, 'grid', get: => @blockArray()

            ## Populate block
            'do' while (=>

                @blocks = []

                for y in [-1..2]    
                    @blocks.push b for b in @createRow y

                @getMatches().length > 0 
            )()


            ## Set Up Cursor
            @cursor = new Positional
            @cursor.limit [0, @width-2, 0, @height-2]

            ## start game ticker
            zz.game.ticker.on 'tick', => @tick()

        #########################
        ## Retreival functions
        #########################
        
        ##
        # Formats the array of blocks into a grid
        blockArray: ->
            # return @_blockArray if @_blockArray?

            @_blockArray = []
            @_blockArray.fill @width, @height

            for b in @blocks
                @_blockArray[b.x][b.y] = b if b.y >= 0

            return @_blockArray

        ## 
        # Gets a column from a block or
        # numerical argument
        getColumn: (col)->
            col = col.x if col.x?

            return @grid[col]

        ##
        # Gets a row from a block or 
        # numerical argumenet
        getRow: (row)->
            row = row.y if row.y?

            return (@grid[i][row] for i in [0..@width-1])

        ## 
        # Returns a list of rows
        getRows: -> @getRow i for i in [0..@height-1]

        ## 
        # Returns a list of columns
        getColumns: -> @grid

        ## 
        # Returns a list of all blocks adjacent to a block
        getAdjacent: (block)->
            grid = @grid

            blocks = []
            blocks.push grid[block.x][block.y+1]
            blocks.push grid[block.x][block.y-1]

            blocks.push grid[block.x-1][block.y] if grid[block.x-1]?
            blocks.push grid[block.x+1][block.y] if grid[block.x+1]?

            return (b for b in blocks when b?)

        ##
        # Timer Stop 
        pause:   -> @paused = true

        ## 
        # Timer continue
        continue: -> @paused = false

        ##
        # Main loop, pushing up rows
        tick: ()->
            @counter++ unless @paused

            if @counter > @speed
                @counter = 0
                @pushRow() 
                @speed *= 0.95

        ## 
        # Push up a row
        pushRow: ()->
            b.y++ for b in @blocks
            @cursor.move 0, 1
            @blocks.push b for b in @createRow -1
            @updateGrid()

        ## 
        # Return an array of new blocks
        createRow: (y)-> 
            (new Block(x, y) for x in [0..@width-1])

        ##
        # Add a group and the groups blocks
        addGroup: (group)->
            @groups.push group
            @addBlocks group.blocks

        ##
        # Add a blocks and update the grid
        addBlocks: (blocks)->
            for b in blocks
                @blocks.push b

            @updateGrid()

        
        ##################################
        # Loss functionality
        #################################
        
        ## 
        # Checks for loss
        checkLoss: ->
            for b in @blocks
                return @lose() if b.y >= @height-1 and b.canLose

        ## 
        # Triggered on loss of game
        lose: ->
            @stop()
            @emit 'loss', this

        ## 
        # Swaps two blocks under the cursor
        swap: ()->
            x = @cursor.x

            b1 = @grid[x][@cursor.y]
            b2 = @grid[x+1][@cursor.y]

            return unless b1? or b2?
            return if b1? and not b1.canSwap
            return if b2? and not b2.canSwap

            @queue 'swap', [b1,b2], =>
                b1.x = x+1 if b1?
                b2.x = x if b2?
                @updateGrid()

        ##
        # Moves the cursor with an event emition
        moveCursor: (x,y)->
            @emit 'cursorMove'
            @cursor.move(x,y)



        #########################
        # Match Checking
        #########################
            
        ##
        # Checks for all matches on the board
        getMatches: ->
            matches = []
            for row in @getRows()
                matches.push a for a in @checkRow(row)

            for col in @getColumns()
                matches.push a for a in @checkRow(col)

            return matches

        ##
        # Checks a row or column 
        # for matches
        # returns an array of sets
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

        ##
        # Checks two blocks for a match
        checkBlocks: (b1, b2)->
            return false unless b1? and b2?
            return false unless b1.color and b2.color
            b1.color == b2.color

        
        ## 
        # Clears matches from a matches array 
        clearMatches: (matches)->
            for m in matches
                @clearBlocks m 
                @checkDisperse m

            return @scoreMatches matches

        ##
        # Clears a list of blocks
        clearBlocks: (blocks)->
            blocks = [blocks] unless blocks.length

            for b in blocks
                @emit 'remove', b
                @blocks.remove(b)


        ###########################
        # Dispersal Functionality
        ############################

        ##
        # Checks for the dispersal of a big block. 
        checkDisperse: (blocks)->
            for block in blocks
                for b in @getAdjacent block
                    return @disperseGroup b.group  if b.group?

        ##
        # Disperses a group
        disperseGroup: (group)->
            return unless @groups.indexOf group > -1
            @groups.remove group

            newBlocks = (new Block(block.x, block.y) for block in group.blocks)

            @queue 'dispersal', {oldBlocks: group.blocks, newBlocks: newBlocks}, ()=>
                @addBlocks newBlocks
                @clearBlocks group.blocks
            
        ## 
        # Calculates the score for a match set
        scoreMatches: (matches)->
            score = 0 
            mult = 1

            matches  = matches.sort (a,b)->
                return a.length - b.length

            for set in matches
                score += mult * set.length * 10
                mult += 1

            return score

        ## 
        # Updates the grid
        # Chain is number of matches 
        updateGrid: (chain=0, score=0)->

            # First move all blocks down
            @fallDown()

            # Then move all groups (blocks never ontop of groups)
            @groupFallDown()

            ## Check for lose
            @checkLoss()

            ## get all matches
            matches = @getMatches()

            ## Return if no matches and no chain
            if matches.length == 0 and score == 0 
                return

            ## End of chain
            else if matches.length == 0 and score > 0 
                @score += score * chain
                return

            ## Hold blocks in match
            for set in matches
                for block in set
                    block.canSwap = false

            @queue 'match', matches, =>
                score += @clearMatches matches
                @updateGrid chain+1, score


        ## Fall Down Indivitual Blocks
        fallDown: ->
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

        groupFallDown: ->
            ## Fall Down Groups
            for group in @groups

                distances = []
                for block in group.bottom
                    d = 1 
                    d++ while not @grid[block.x][block.y - d]? and block.y - d > 0
                    distances.push d

                minDist = distances.min() - 1
                # if not group.active
                #     @queue 'groupMove', [group, minDist], =>
                #         group.moveAll 0,-minDist
                #         group.activate()
                #         @checkLoss()
                # else 
                group.moveAll 0, -minDist

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
    
    ## Start Menu Manager
    new Manager()

    return zz
)