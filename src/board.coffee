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

        @blocks  = []

        @groups  = []

        @score = 0

        @stopped = false

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
        @cursor = new zz.class.positional
        @cursor.limit [0, @width-2, 0, @height-2]

        ## start game ticker
        zz.game.ticker.on 'tick', =>
            return if @stopped
            @counter++ unless @paused

            if @counter > @speed
                @counter = 0
                @pushRow() 
                @speed *= 0.95


    checkLoss: ->
        for b in @blocks
            if b.y >= @height-1 and b.active
                return @lose()

    lose: ->
        @stop()
        @emit 'loss', this

    createRow: (y)-> 
        (new ColorBlock(x, y) for x in [0..@width-1])

    pushRow: ()->
        b.y++ for b in @blocks
        @cursor.move 0, 1

        @blocks.push b for b in @createRow -1

        @update()

    addGroup: (group)->
        @groups.push group
        @addBlocks group.blocks

    blockArray: ->
        # return @_blockArray if @_blockArray?

        @_blockArray = []
        @_blockArray.fill @width, @height

        for b in @blocks
            @_blockArray[b.x][b.y] = b if b.y >= 0

        return @_blockArray

    swap: ()->
        b1 = @grid[@cursor.x][@cursor.y]
        b2 = @grid[@cursor.x+1][@cursor.y]

        x = @cursor.x

        return if b1? and not b1.canSwap
        return if b2? and not b2.canSwap


        @queue 'swap', [b1,b2], =>
            b1.x = x+1 if b1?
            b2.x = x if b2? 
            @update()


    moveCursor: (x,y)->
        @emit 'cursorMove'
        @cursor.move(x,y)


    #########################
    ## Retreival functions
    #########################
    getColumn: (col)->
        col = col.x if col.x?

        return @grid[col]

    getRow: (row)->
        row = row.y if row.y?

        return (@grid[i][row] for i in [0..@width-1])

    getRows: ()->
        @getRow i for i in [0..@height-1]

    getColumns: ()-> @grid

    getAdjacent: (block)->
        grid = @grid

        blocks = []
        blocks.push grid[block.x][block.y+1]
        blocks.push grid[block.x][block.y-1]

        blocks.push grid[block.x-1][block.y] if grid[block.x-1]?
        blocks.push grid[block.x+1][block.y] if grid[block.x+1]?

        return (b for b in blocks when b?)

    #########################
    ## Match Functions
    #########################
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

    checkBlocks: (b1, b2)->
        return false unless b1? and b2?
        return false unless b1.color and b2.color
        b1.color == b2.color

    getMatches: ->
        matches = []
        for row in @getRows()
            matches.push a for a in @checkRow(row)

        for col in @getColumns()
            matches.push a for a in @checkRow(col)

        return matches

    clearMatches: (matches)->
        for m in matches
            @clearBlocks m 
            @checkDisperse m


    scoreMatches: (chain, matches)->
        score = 0 
        matches  = matches.sort (a,b)->
            return a.length - b.length

        for set in matches
            setScore = chain * set.length * 10
            @emit 'scoring', [chain, setScore, set]
            score += setScore
            chain++

        return score

    addBlocks: (blocks)->
        for b in blocks
            @emit 'add', b
            @blocks.push b

        @update()

    clearBlocks: (blocks)->
        blocks = [blocks] unless blocks.length

        for b in blocks
            @emit 'remove', b
            @blocks.remove(b)

    checkDisperse: (blocks)->
        for block in blocks
            for b in @getAdjacent block
                return @disperseGroup b.group  if b.group?

    disperseGroup: (group)->
        return unless @groups.indexOf group > -1
        @groups.remove group

        newBlocks = (new ColorBlock(block.x, block.y) for block in group.blocks)

        @queue 'dispersal', {oldBlocks: group.blocks, newBlocks: newBlocks}, ()=>
            @addBlocks newBlocks
            @clearBlocks group.blocks
        

    update: (chain=1)->
        @_blockArray = null

        @fallDown()
        @checkLoss()

        zz.game.renderer.render() if zz.game.renderer.render?

        matches = @getMatches()

        if matches.length == 0
            @emit 'chainComplete', chain
            return

        for set in matches
            for block in set
                block.canSwap = false

        score = @scoreMatches chain, matches
        @emit 'score', score
        @score += score

        @queue 'match', matches, =>
            @clearMatches matches
            @update(chain+1)
            @emit 'matchComplete', matches


    ## Fall Down Indivitual Blocks
    fallDown: ()->
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

        ## Fall Down Groups
        for group in @groups

            distances = []
            for block in group.bottom
                d = 1 
                d++ while not @grid[block.x][block.y - d]? and block.y - d > 0
                distances.push d

            minDist = distances.min() - 1
            if not group.active
                @queue 'groupMove', [group, minDist], =>
                    group.moveAll 0,-minDist
                    group.activate()
                    @checkLoss()
            else 
                group.moveAll 0,-minDist



    pause:   -> @paused = true
    continue: -> @paused = false
    stop: -> @stopped = true


    # fallDown: ->
    #     for col in @getColumns()
    #         col = col.sort (b1,b2)->
    #             y1 = if b1? then b1.y else 1000
    #             y2 = if b2? then b2.y else 1000
    #             y1 - y2


    #         for i in [0..col.length-1]
    #             col[i].y = i if col[i]?

