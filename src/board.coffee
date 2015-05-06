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

        ## start game ticker
        zz.game.ticker.on 'tick', => @tick() unless clone

        @updateGrid() unless clone

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
        @counter++ unless @paused

        if @counter > @speed
            @counter = 0
            @pushRow() 
            @speed *= 0.95

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
        @emit 'loss', this
        @opponent.pause() if @opponent?

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
        return unless @opponent?
        # return if score < 50

        shapes = 
            # 20:  [7,3]
            100: [3,2]
            150: [7,2]
            200: [3,3]
            300: [7,3]


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


