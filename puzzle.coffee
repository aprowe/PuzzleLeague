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

    		@useQueue = true

    		for key, value of @defaults
    			this[key] = value

    	on: (event, fn, state='')->
    		return (@on event, fn, s for s in state) if typeof state is 'object' and state.length?
    		unless @_events[''+event+state]?
    			@_events[''+event+state] = []

    		@_events[''+event+state].push fn

    	unbind: (event, fn)->
    		unless fn?
    			@_events[event] = []
    		# @TODO

    	emit: (event, args, state=false)->
    		@emit ''+event+zz.game.state, args, true unless state
    		## Call the function on<event>
    		return false unless @_events[event]?
    		fn.call(this, args) for fn in @_events[event]
    		return true

    	done: (event, args)->
    		return unless @_queue[event]?
    		fn = @_queue[event].shift()
    		return unless fn?
    		fn.call this, args

    	queue: (event, args, fn)->
    		@_queue[event] = [] unless @_queue[event]?
    		@_queue[event].push fn
    		@emit event, args

    		@done event if not @useQueue


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
    class Ticker extends Base

    	## Total frames elapsed
    	elapsed: 0

    	constructor: (framerate=60)->
    		super

    		## Frames per second
    		@framerate = framerate

    		## Is Ticker paused?
    		@running = false


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

    ## Game States
    STATE = 
    	MENU: 'menu'
    	PLAYING: 'playing'
    	OVER: 'over'
    	PAUSED: 'paused'

    ############################################
    ## Game Class singleton
    ############################################

    class Game extends Base

    	defaults:
    		## Player boards
    		boards: []

    		## Ticker Class
    		ticker: {}

    		## Rending Class
    		renderer: {}


    	@settings: 
    		players: 1
    		music: 1.0
    		sound: 1.0
    		computer: true


    	## Initialize game
    	constructor: ()->
    		super

    		## Set the pointer
    		zz.game = this

    		## Initialize State
    		@state = STATE.MENU

    		## Initialize Ticker
    		@ticker = new Ticker()


    		## Set up main game loop
    		@ticker.on 'tick', => @loop()

    		## Start the key controller
    		@key = new KeyListener

    		## start Music controller
    		@music = new MusicController

    		## Start Sound Controller
    		@sound = new SoundController

    		## Start Menu Manager
    		@manager = new Manager

    	setState: (state)->
    		@state = state
    		@emit 'state', state

    	initBoards: ->
    		@boards = []
    		@boards.push new Board(0)
    		new  PlayerController @boards[0]

    		if @settings.players == 2
    			@boards.push new Board(1)
    			@boards[0].opponent = @boards[1]
    			@boards[1].opponent = @boards[0]

    			if @settings.computer
    				new ComputerController @boards[1]
    			else
    				new PlayerController @boards[1]

    		for b in @boards
    			b.on 'lose', =>
    				console.log @state
    				@setState STATE.OVER



    	## Start Ticker and game
    	start: (settings)->
    		## extend settings
    		@settings = $.extend Game.settings, settings, true

    		## Initialize Boards
    		@initBoards()

    		## Start the renderer
    		@renderer = new CanvasRenderer this

    		## Start board sound controller
    		new BoardSoundController(b) for b in @boards
    		
    		## Start the ticker
    		@ticker.start()

    		## Change State
    		@setState STATE.PLAYING

    		## emit start 
    		@emit 'start'
    		

    	continue: ->
    		@emit 'continue'
    		@ticker.start()

    		## Change State
    		@setState STATE.PLAYING

    	stop: ->
    		@emit 'stop'
    		@ticker.stop()
    		delete @boards
    		delete @ticker

    		## Change State
    		@setState STATE.MENU

    	pause: ->
    		@emit 'pause'
    		@ticker.stop()

    		## Change State
    		@setState STATE.PAUSED

    	restart: ->
    		@stop()
    		@start()


    	## Main Game Loop
    	loop: ->
    		@renderer.render()





    ## Class to Manage Menu Screens
    class Manager

        constructor: ()->
            @settings = {}

            @menus = {}

            @actions =
                startSingle: =>
                    zz.game.start players: 1

                vsFriend: => 
                    zz.game.start  
                        players: 2
                        computer: false

                vsComputer: =>
                    zz.game.start  
                        players: 2
                        computer: true

                continue: => zz.game.continue()

                exit: => zz.game.stop()

                fullscreen: => $(document).toggleFullScreen()

            zz.game.key.on 'ESC', => 
                zz.game.pause() 
            , STATE.PLAYING

            zz.game.key.on 80, => 
                zz.game.pause() 
            , STATE.PLAYING

            zz.game.key.on 'ESC', => 
                zz.game.continue()
            , STATE.PAUSED

            zz.game.key.on 80, => 
                zz.game.continue()
            , STATE.PAUSED

            zz.game.key.on 'DOWN', => 
                @highlight 1
                zz.game.sound.play 'click'
            , [STATE.MENU, STATE.PAUSED]

            zz.game.key.on 'UP',    => 
                @highlight -1 
                zz.game.sound.play 'click'
            , [STATE.MENU, STATE.PAUSED]

            zz.game.key.on 'SPACE', => 
                @highlight 0
                zz.game.sound.play 'click'
            , [STATE.MENU, STATE.PAUSED]

            zz.game.key.on 'RETURN', => 
                @highlight 0
                zz.game.sound.play 'click'
            , [STATE.MENU, STATE.PAUSED]

            zz.game.key.on 'RETURN', =>
                zz.game.stop()
            , STATE.OVER

            zz.game.key.on 'ESC', =>
                zz.game.stop()
            , STATE.OVER

            zz.game.on 'start', =>

            zz.game.on 'pause', =>
                @showMenu 'pause'

            zz.game.on 'continue', =>
                @showMenu null

            zz.game.on 'stop', =>
                window.location = '/'

            zz.game.on 'state', (state)=>
                $('body').attr('class', '')
                $('body').addClass "state-#{state}"


            @setUpMenu()

        setUpMenu: ->
            that = this

            @menus = $('.menu')
            @menus.find('div').click ->

                id = $(this).data 'menu'
                that.showMenu id if id? 
                    
                action = $(this).data 'action'
                that.actions[action].call(that) if action?

            .mouseover -> that.highlight $(this)

            @showMenu('main')

        showMenu: (id)->
            $('.menu.active').removeClass 'active'
            return unless id?
            menu = $(".menu##{id}").addClass('active')
            @highlight menu.children('div').first()

        highlight: (index)->
            if index == 0 and $('.highlight').length != 0 
                $('.highlight').click()
                return

            if index? and index.jquery?
                $('.highlight').removeClass('highlight')
                index.addClass ('highlight')
                return

            item = $('.menu.active .highlight')

            if item.length == 0 
                @highlight $('.menu.active').children('div').first()
                return

            return @highlight item.next('div') if index == 1 and item.next('div').length > 0 
            return @highlight item.prev('div') if index == -1 and item.prev('div').length > 0 


    ################################
    ## Rendering Class
    ################################

    class Renderer extends Base

        boardRenderer: ->

        constructor: ->
            super

            $('.puzzle').hide()

            @boards = []
            for b, i in zz.game.boards
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

        renderBackground: ->
        renderBlock:  (block)->
        renderCursor: (cursor)->
        renderScore:  ()->

        offset: ()-> 
            @board.counter / @board.speed * @size

        toPos: (pos)->
            x: pos.x * @size
            y: (@board.height - pos.y - 1) * @size



    ## Main Rendering Class
    class CanvasBoardRenderer extends BoardRenderer

        #################################
        ## Init Functions
        #################################
        init: ()->

            @id  = "puzzle-#{@board.id}"

            ## Set up board size
            $("##{@id}").attr
                width: @board.width * @size
                height: @board.height * @size
            .show()

            @stage = new createjs.Stage @id

            @loadSprites()
            
            @animate 'start'
            @animate 'swap'
            @animate 'match'
            @animate 'lose'
            @animate 'win'
            @animate 'dispersal'
            @animate 'addGroup'

            @board.on 'remove', (b)=>
                @stage.removeChild b

            @board.on 'scoreChange', =>
                @renderScore()

            @board.on 'logScore', (score)=>
                return unless score >= 50
                $('<div></div>', class: 'color').insertAfter $('.combos').children().first()
                    .html (score)

                if $('.combos').length > 20
                    $('.combos').children().last.remove()

            @renderScore()

            @text = null

            @initCookies()
            @board.on 'refreshHigh', =>
                @initCookies()

        initCookies: ->
            cookie = Cookies('highscores')
            Cookies('highscores', JSON.stringify([]), {expires:Infinity}) unless cookie?
            @scores = $.parseJSON cookie

            $('#highscores').html ''
            for score in @scores
                $('<tr></tr>').append("<td>#{score.name}<td>").append("<td class='color'>#{score.score}<td>")
                    .appendTo '#highscores'


        initScore: ->
            $("#player-#{@board.id} .scoreboard").show()
            $('.combos').hide() if @board.id > 0

        initBlock: (block)->

            animation = 'still'

            if block.y < 0 
                animation = 'matched'

            block.s = new createjs.Sprite @sprites[block.color], animation


            @release block
            @renderBlock block

            @stage.addChildAt block.s, @stage.children.length - 1, 


        initCursor: (cursor)->
            cursor.s = new createjs.Shape()

            cursor.s.graphics
                .setStrokeStyle 2
                .beginStroke 'white'
                .drawRect 0, 0, @size*2, @size

            @stage.addChild cursor.s

        #################################
        ## Render / Update functions
        #################################
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

            if b.y == -1 and not b._activated? and @offset() >= @size-1
                b.s.gotoAndPlay 'activate'
                b._activated = true

            pos = @toPos b
            b.s.x = pos.x + 1 
            b.s.y = pos.y - @offset() + 1


        renderScore: ->
            $("#player-#{@board.id} .score").html(@board.score)
            $("#player-#{@board.id} .speed").html(@board.speedLevel)

        #################################
        # Animations
        #################################
        animate: (event)->
            @board.on event, =>
                this[event+'Animation'].apply(this, arguments)

        after: (length, fn)-> setTimeout fn, length
        
        ## 
        # 'Holds' a block, not letting it update it's position 
        hold: (obj)-> 
            return (@hold o for o in arguments) if arguments.length > 1?
            return unless obj?
            return (@hold o for o in obj) if obj.length? and obj.length > 1?
            obj._stop = true

        ##
        # Releases a block so its position is updated
        release: (obj)-> 
            return (@release o for o in arguments) if arguments.length > 1?
            return unless obj?
            return (@release o for o in obj) if obj.length? and obj.length > 1?
            obj._stop = false
            
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

            @after length, =>
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

            @after length, =>
                @board.continue()
                @release set for set in matches
                @board.done 'match'

        dispersalAnimation: (args)->

            oldBlocks = args.oldBlocks
            newBlocks = args.newBlocks

            perLength = 100
            length = perLength * (newBlocks.length+1)

            @hold oldBlocks

            for b, i in newBlocks
                fn = ((b)=>
                    return => @initBlock b
                )(b)

                setTimeout fn, i*perLength

            @after length, =>
                @stage.removeChild(b.s) for b in oldBlocks
                @board.done 'dispersal'

        addGroupAnimation: (group)->
            length = 1000

            for b in group.blocks
                @initBlock b unless b.s
                @renderBlock b 
                @hold b
                # pos = @toPos(b).y * @size + @offset()
                tmp = b.s.y
                b.s.y = tmp - @size * @board.height - group.h
                createjs.Tween.get(b.s).to({y: tmp}, length, createjs.Ease.bounceOut)

            @after length, =>
                @release b for b in group.blocks


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

        loseAnimation: ->
            for b in @board.blocks
                # @hold b 
                b.color = 0
                @stage.removeChild b.s
                @initBlock b
                b.s.gotoAndPlay 'lost'

            if @board.opponent?
                @message "Defeat" 
            else
                @message "Game\nOver"

        winAnimation: ->
            @message "Victory!"

        message: (message)->
            @clearText()
            text = new createjs.Text message, "40px '8BIT WONDER'", 'white'
            text.shadow = new createjs.Shadow("#000000", 9, 9, 0);
            text.y = 100
            text.x = @stage.getBounds().width/2 - text.getBounds().width/2
            @stage.addChild text
            @text = text

        clearText: ->
            @stage.removeChild @text if @text?

        startAnimation: ->
            @message "Get\nReady"

            console.log 'ahere'
            setTimeout =>
                @clearText()
                @board.done 'start'
                console.log 'here'
            , 1500

        loadSprites: ()->
            @sprites = []
            data = 
                frames:
                    width: 32
                    height: 32

                animations:
                    still: 5
                    fillIn: [0,1,2,3,4,5]
                    fillOut: [5,4,3,2,1,0]
                    matching: 
                        frames: [0,1,2,3,4,5,4,3,2,1]
                        # next: 'matched'
                        speed: 0.75
                    matched: 0
                    lost: 
                        frames: [5,4,3,2,1,0]
                        next: 'matched'
                        speed: 0.1
                    activate:
                        frames: [0,1,2,3,4,5]
                        next: 'still'
                        speed: 0.5


            # data.animations.still = 0 
            data.images = ["assets/sprites/grey.png"]
            @sprites.push new createjs.SpriteSheet data

            # data.animations.still = 5
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

    class KeyListener extends Base

        MAP:
            LEFT:   37
            UP:     38
            RIGHT:  39
            DOWN:   40
            SPACE:  32
            RETURN: 13
            ESC:    27
            SHIFT:  16

        constructor: ->
            super
            @listening = true

            $ => $('body').keydown (e)=>
                return unless @listening
                console.log e.which
                if @emit e.which 
                    e.preventDefault(e)

        on: (key, fn, state)->
            key = @MAP[key] if @MAP[key]?
            super key, fn, state

        start: ()->
            @listening = false

        stop: ()->
            @listening = true


    class Controller extends Base

        board: {}

        constructor: (@board)->
            super

        keys: [
            'up',
            'down',
            'left',
            'right',
            'swap',
            'advance'
        ]

        events:
            up:       -> @board.moveCursor  0, 1
            down:     -> @board.moveCursor  0,-1
            left:     -> @board.moveCursor -1, 0
            right:    -> @board.moveCursor  1, 0
            swap:     -> @board.swap()
            advance:  -> @board.counter+=30

        dispatch: (key, args)-> 
            return unless zz.game.state == STATE.PLAYING
            @events[key].call(this, args) if @events[key]?

    class PlayerController extends Controller


        keyMaps: [
            {
                ## Player 1
                LEFT:  'left'
                UP:    'up'
                RIGHT: 'right'
                DOWN:  'down'
                SPACE: 'swap'
                ESC:   'exit'
                77:    'swap'
                80:    'exit'
            },
            {
                ## Player 2
                65: 'left'
                87: 'up'
                68: 'right'
                83: 'down'
                SHIFT: 'swap'
                81: 'swap'
            }
        ]



        constructor: (@board)->
            super @board

            @map = @keyMaps[@board.id]

            for key, value of @map
                zz.game.key.on key, ((v)=>
                    => @dispatch v
                )(value)


    class ComputerController extends Controller

        speed: 500

        levels: 1

        constructor: (@board)->
            super @board

            t = new Ticker(4)
            t.on 'tick', => @evaluate()
            t.start()

            @board.on 'update', =>
                @target = null if @target == 'wait'

            @target = null

            @lastTarget = null

        evaluateBoard: (board, level=0, top=true)->
            trials = []

            swaps = []

            for b in board.blocks
                continue unless b.canSwap
                continue if b.y < 0 

                p1 = {x: b.x,   y: b.y}
                p2 = {x: b.x-1, y: b.y}

                p1.score = -10000 * b.y if b.color == 0

                swaps.push p1 if swaps.indexOf(p1) == -1 and p1.x < board.width - 2
                swaps.push p2 if swaps.indexOf(p2) == -1 and p2.x > 0


            
            for b in swaps
                tmp = board.clone()
                tmp.useQueue = false

                tmp.cursor.x = b.x
                tmp.cursor.y = b.y

                continue unless tmp.swap()

                tmp.score += b.score if b.score?

                if b.y > 5
                    tmp.score -= b.y * 10

                if b.y > 8
                    tmp.score -= b.y * 10000

                if level > 0 
                    best = @evaluateBoard tmp, level - 1, false
                    tmp.score += best.score * 0.9

                trials.push 
                    x: b.x
                    y: b.y
                    score: tmp.score + Math.random()

            trials.sort (a,b)->
                (a.score - b.score)


            return trials if top
            return trials.pop()


        evaluate: ()->
            return @goto @target if @target

            trials = @evaluateBoard @board, 1

            best = trials.pop()

            # if best.score > 0 
            @target = best
            # else
                # @target = 'wait'



        goto: (target)->
            return unless target.x?

            diff = 
                x: target.x - @board.cursor.x
                y: target.y - @board.cursor.y
                
            if diff.x == 0 and diff.y == 0 
                @dispatch 'swap'
                @lastTarget = @target
                @target = null
                return

            if diff.x < 0
                @dispatch 'left'
                return

            else if diff.x > 0
                @dispatch 'right' 
                return

            else if diff.y > 0
                @dispatch 'up'    
                return

            else if diff.y < 0
                @dispatch 'down'
                return










    class SoundController extends Base

    	sounds:
    		click: 'click.wav'
    		slide: 'slide.wav'
    		match: 'match0.wav'

    	constructor: ->
    		for key,value of @sounds
    			createjs.Sound.registerSound "assets/sounds/#{value}", key
    		
    	play: (sound, settings={})->
    		createjs.Sound.play sound
    			

    class MusicController extends Base


    	initialize: ->
    		files = [ 
    			{
    				id: 'intro'
    				src: 'intro.mp3'
    			},
    			{
    				id: 'mid'
    				src: 'mid.mp3'
    			}
    		]

    		for f in files
    			f.src = 'assets/music/' + f.src

    		createjs.Sound.alternateExtensions = ["mp3"];
    		createjs.Sound.registerSounds files

    	constructor: ->
    		@initialize()
    		@current = null

    		zz.game.on 'start', =>
    			@current = createjs.Sound.play 'intro'
    			@current.on 'complete', =>
    				@current = createjs.Sound.play 'mid'
    				@current.loop = true
    				@current.volume = zz.game.settings.music

    		zz.game.on 'pause', =>
    			@current.volume = zz.game.settings.music / 3.0

    		zz.game.on 'continue', =>
    			@current.volume = zz.game.settings.music


    class BoardSoundController extends Base

    	events: [{
    			on: 'match'
    			sound: 'match'
    			settings: 
    				volume: 0.5
    		},{
    			on: 'cursorMove'
    			sound: 'click'
    			settings: 
    				volume: 0.5
    		},{
    			on: 'swap'
    			sound: 'slide'
    			settings: 
    				volume: 0.5
    		}
    	]

    	constructor: (@board)->
    		for event in @events
    			@board.on event.on, ((e)=> =>
    				createjs.Sound.play e.sound, e.settings
    			)(event)


    ############################################
    ## Board class does most of the game logic
    ############################################
    zz.class.board = class Board extends zz.class.base

        ## Width of board
        width: 8

        ## Height of board
        height: 12

        constructor: (@id, clone=false)->
            super

            ## Array of blocks
            @blocks  = []

            ## Array of groups
            @groups  = []

            ## initial score
            @score = 0

            ## board instance of opponent
            @opponent = null

            ## indicates this game is lost or not
            @lost = false

            ## Keeps track of the row increment
            @counter = 0 

            ## Speed of rows rising
            @speed = 60*15

            @speedLevel = 1

            @speedCounter = 0 

            ## Set up easy grid getter
            Object.defineProperty this, 'grid', get: => @blockArray()

            ## Populate block
            'do' while (=>

                @blocks = []

                for y in [-1..2]    
                    @blocks.push b for b in @createRow y

                @getMatches().length > 0 
            )() unless clone


            ## Set Up Cursor
            @cursor = new Positional
            @cursor.limit [0, @width-2, 0, @height-2]

            return if clone
            ## start game ticker
            zz.game.ticker.on 'tick', => @tick()

            @updateGrid()

            @paused = true
            setTimeout =>
                @queue 'start', [], =>
                    @paused = false
            , 100

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
            return if @paused

            @counter++
            @speedCounter++

            if @counter > @speed
                @counter = 0
                @pushRow() 

            if @speedCounter % (60 * 15) == 0
                @speedLevel++
                @speed *= 0.95
                @emit 'scoreChange'

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
            @blocks.push b for b in group.blocks
            @updateGrid()
            @emit 'addGroup', group

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
            @pause()
            @emit 'lose', this
            @opponent.pause() if @opponent?
            @opponent.win() if @opponent?
            @writeCookie()

        win: -> 
            @emit 'win'
            @writeCookie()

        ## 
        # Swaps two blocks under the cursor
        swap: ()->
            x = @cursor.x

            b1 = @grid[x][@cursor.y]
            b2 = @grid[x+1][@cursor.y]

            return false unless b1? or b2?
            return false if b1? and not b1.canSwap
            return false if b2? and not b2.canSwap

            @queue 'swap', [b1,b2], =>
                b1.x = x+1 if b1?
                b2.x = x if b2?
                @updateGrid()

            return true

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
            return false unless b1.canMatch and b2.canMatch
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

            @pause()

            @queue 'dispersal', {oldBlocks: group.blocks, newBlocks: newBlocks}, ()=>
                @addBlocks newBlocks
                @clearBlocks group.blocks
                @continue()
            
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
                @emit 'update'
                return

            ## End of chain
            else if matches.length == 0 and score > 0 
                @score += score * chain
                @sendBlocks score * chain
                @emit 'update'
                return

            ## Hold blocks in match
            for set in matches
                for block in set
                    block.canSwap = false
                    block.canMatch = false

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
            grid = @grid
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
                group.activate()


        sendBlocks: (score)->
            @emit 'logScore', score
            @emit 'scoreChange'
            return unless @opponent?
            # return if score < 50

            shapes = 
                # 20:  [7,3]
                100: [8,1]
                200: [8,2]
                300: [8,3]


            for thresh, dim of shapes
                if score >= Number(thresh)
                    w = dim[0]
                    h = dim[1]

            x = Math.random() * (@opponent.width - w)
            x = Math.round x

            y = @opponent.height-h

            @opponent.addGroup new BlockGroup(x,y,w,h)

        clone: ()->
            board = new Board(2, true)
            board.blocks = []
            board.blocks.push b.clone() for b in @blocks
            return board

        writeCookie: ()->
            return if zz.game.settings.computer and @id==1
            return if @cookie?
            @cookie = true
            setTimeout =>
                scores = $.parseJSON Cookies('highscores')

                if scores.length < 10 or @score > scores[scores.length-1].score 
                    name = prompt 'Highscore! Please enter your name:'
                    score = @score
                    scores.push {name: name, score: score}
                    scores.sort (a,b)-> b.score - a.score
                    scores = scores[0..9]
            
                    Cookies 'highscores', JSON.stringify(scores), expires: Infinity
                    @emit 'refreshHigh'
            , 2000


    ############################################
    ## Block class for each block on the grid
    ############################################
    zz.class.block = class Block extends Positional

    	colors: 5

    	constructor: (@x, @y)->
    		@canSwap = true
    		@canLose = true
    		@canMatch = true
    		@color = @randomColor()
    		super @x, @y

    	randomColor: ->
    		Math.round(Math.random()*@colors)%@colors + 1

    	clone: ->
    		b = new Block()
    		b.color = @color
    		b.x = @x
    		b.y = @y
    		
    		return b


    class GrayBlock extends Block

    	constructor: (@x, @y, @group)->
    		super @x, @y

    		@color = 0
    		@canSwap = false
    		@canMatch = false

    		# Block must fall down before 
    		# it can be counted against lost
    		@canLose = false

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
    			b = new GrayBlock @x + i, @y + j, this

    			@bottom.push b if (j == 0)
    			@blocks.push b


    	moveAll: (x,y)->
    		b.move(x,y) for b in @blocks

    	activate: ()->
    		b.canLose = true for b in @blocks
    		@canLose = true
    
    $ -> zz.game = new Game()

    return zz
)