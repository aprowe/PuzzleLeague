

## Class to Manage Menu Screens
class Manager

    constructor: ()->
        @settings = {}

        @menus = {}

        @actions =
            startSingle: =>
                @settings.players = 1
                @startGame()

            vsFriend: => 
                @settings.players = 2
                @settings.computer = false
                @startGame()

            vsComputer: =>
                @settings.computer = true
                @settings.players = 2

                @startGame()

            continue: => @pauseResume()

            exit: => @endGame()

        zz.keyListener.on 'ESC', (=> @pauseResume())
        zz.keyListener.on 'ESC', (=> @pauseResume()), 'menu'
        zz.keyListener.on 'DOWN', (=> @highlight(1)), 'menu'
        zz.keyListener.on 'UP', (=> @highlight(-1)), 'menu'
        zz.keyListener.on 'SPACE', (=> @highlight(0)), 'menu'
        zz.keyListener.on 'RETURN', (=> @highlight(0)), 'menu'

        $ => 
            @setUpMenu()

    setUpMenu: ->
        that = this

        @menus = $('.menu')
        @menus.find('div').click ->

            id = $(this).data 'menu'
            that.showMenu id if id? 
                
            action = $(this).data 'action'
            that.actions[action].call(that) if action?

        .mouseover -> that.highlight $(this)

        @showMenu('main')

    showMenu: (id)->
        $('.menu.active').removeClass 'active'
        menu = $(".menu##{id}").addClass('active')
        @highlight menu.children().first()

    highlight: (index)->
        if index == 0 and $('.highlight').length != 0 
            $('.highlight').click()
            return

        if index? and index.jquery?
            $('.highlight').removeClass('highlight')
            index.addClass ('highlight')
            return

        item = $('.menu.active .highlight')

        if item.length == 0 
            @highlight $('.menu.active').children().first()
            return

        @highlight item.next() if index == 1 and item.next().length > 0 
        @highlight item.prev() if index == -1 and item.prev().length > 0 

    startGame: (mode)->
        $('.main').hide()
        @game = new Game(@settings)
        @game.start()
        zz.keyListener.state = 'default'
    
    pauseResume: ()->
        if @game.ticker.running
            @game.pause()
            @showMenu 'pause'
            zz.keyListener.state = 'menu'
        else 
            @game.continue()
            $('#pause').removeClass('active')
            zz.keyListener.state = 'default'
            

    endGame: ->
        window.location = '/'
        @game.stop()
        $('.main').show()
        $('.puzzle').hide()
        @showMenu('main')

