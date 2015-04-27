

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

            continue: => 
                @game.start()
                $('#pause').hide()

            exit: => @endGame()

        $ => @setUpMenu()

    setUpMenu: ->
        that = this

        @menus = $('.menu')
        @menus.find('div').click ->

            id = $(this).data 'menu'
            that.showMenu id if id? 
                
            action = $(this).data 'action'
            that.actions[action].call(that) if action?


    showMenu: (id)->
        @menus.hide()
        $(".menu##{id}").show()

    startGame: (mode)->
        $('.main').hide()
        @game = new Game(@settings)
        @game.start()
    
    pause: ()->
        console.log @game.ticker
        if @game.ticker.running
            @game.pause()
            $('#pause').show()
        else 
            @game.start()
            $('#pause').hide()

    endGame: ->
        window.location = '/'
        @game.stop()
        $('.main').show()
        $('.puzzle').hide()
        @showMenu('main')
