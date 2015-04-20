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



