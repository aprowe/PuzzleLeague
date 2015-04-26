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

