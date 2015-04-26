

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
                @startGame()

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
    
    endGame: ->
        $('.main').show()
        @game.end()
