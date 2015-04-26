

## Class to Manage Menu Screens
class Manager

    constructor: ()->
        @menus = {}

        @actions =
            startSingle: =>
                @startGame('single')
            vsFriend: => 
                @startGame('multi')

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
        @game = new Game(mode)
        @game.start()
    
    endGame: ->
        $('.main').show()
        @game.end()
