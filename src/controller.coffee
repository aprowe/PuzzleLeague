
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
            # console.log
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
        },
        {
            ## Player 2
            65: 'left'
            87: 'up'
            68: 'right'
            83: 'down'
            SHIFT: 'swap'
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









