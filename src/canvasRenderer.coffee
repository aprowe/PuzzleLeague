
class CanvasBoardRenderer extends BoardRenderer

    colors: [
        'red', 
        'blue',
        'green', 
        'purple',
        'orange',
    ]

    init: ()->
        $('#puzzle').attr width: @board.width * @size , height: @board.height * @size
        
        @stage = new createjs.Stage('puzzle')

        @board.on 'swap', (blocks)=>
            @swapAnimation(blocks)

        @board.on 'match', (matches)=>
            @matchAnimation matches


        @board.on 'remove', (block)=>
            @stage.removeChild block.s 

        @board.on 'add', (block)=>
            @initBlock block

    initBackground: ()->
        @background = new createjs.Shape()
        @background.graphics
            .beginFill 'black'
            .drawRect 0, 0, @size * @board.width, @size * @board.height

        @stage.addChild @background

    initBlock: (block)->
        block.s = new createjs.Shape()

        @release(block)

        color = @colors[block.color]

        block.s.graphics
            .beginFill color
            .drawRect 0, 0, @size, @size
        
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
            console.log 'ok'
            length += 100
            ease = createjs.Ease.quadOut


        t1 = createjs.Tween.get(b1.s).to(x: b1.s.x+@size, length, ease) if b1?
        t2 = createjs.Tween.get(b2.s).to(x: b2.s.x-@size, length, ease) if b2?   

        (new createjs.Tween).wait(length).call =>
            @release b1, b2
            @board.done 'swap'

    matchAnimation: (matches)->
        length = 200

        each = (b)=>
            createjs.Tween.get(b.s).to(alpha: 0, length).play()

        for set in matches
            @hold set
            for block in set
                each(block)

        setTimeout =>
            @release set for set in matches
            @board.done 'match'
        , length



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
