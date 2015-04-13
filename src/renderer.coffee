################################
## Rendering Class
################################

zz.class.renderer = class Renderer extends zz.class.base

    constructor: (@game)->
        super

    render: ()-> 
        @renderBoard @board
        @renderBlock b for b in board.blocks
        @renderCursor board.cursor

    renderBoard:  (board)->
    renderBlock:  (block)->
    renderCursor: (block)->


zz.class.domRenderer = class DomRenderer extends zz.class.renderer

    blockSize: 50

    offset: 0

    colors: [
        'red', 
        'blue',
        'green',
        'yellow',
        'purple',
    ]


    constructor: (@game)->
        throw 'JQuery Not found' unless $?

        @board = @game.boards[0]
        $ => @setUpElement()

    setUpElement: ()->
        @element = $ '#puzzle'
        @element.width  @board.width  * @blockSize
        @element.height @board.height * @blockSize

    render: ()-> 
        @offset = 1.0*@board.counter/@board.speed * @blockSize

        @renderBoard @board
        @renderBlock b for b in @board.blocks
        @renderCursor @board.cursor
        @renderScore()

    renderBoard: (board)->
        @element.find('.block').remove()

    renderCursor: (cursor) ->
        @element.find('.cursor').remove()
        el = $ '<div></div>', class: 'cursor'
            .appendTo @element

        el.width @blockSize * 2
        el.height @blockSize * 1

        el.css
            bottom: cursor.y * @blockSize + @offset
            left: cursor.x * @blockSize

    renderBlock: (block)->
        el = $ '<div></div>', class: 'block'
            .appendTo @element

        el.width @blockSize
        el.height @blockSize

        el.css 
            bottom: block.y * @blockSize + @offset
            left:   block.x * @blockSize 
            background: @colors[block.color]


    renderScore: ->
        $ '#score' 
            .html @board.score
