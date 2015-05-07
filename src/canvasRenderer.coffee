
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

