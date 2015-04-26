
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

