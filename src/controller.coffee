
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




