

## Class to Manage Menu Screens
class Manager

    constructor: ()->
        @settings = {}

        @menus = {}

        @actions =
            startSingle: =>
                zz.game.start players: 1

            vsFriend: => 
                zz.game.start  
                    players: 2
                    computer: false

            vsComputer: =>
                zz.game.start  
                    players: 2
                    computer: true

            continue: => zz.game.continue()

            exit: => zz.game.stop()

            fullscreen: => $(document).toggleFullScreen()

        zz.game.key.on 'ESC', => 
            zz.game.pause() 
        , STATE.PLAYING

        zz.game.key.on 'ESC', => 
            zz.game.continue()
        , STATE.PAUSED

        zz.game.key.on 'DOWN', => 
            @highlight 1
            zz.game.sound.play 'click'
        , [STATE.MENU, STATE.PAUSED]

        zz.game.key.on 'UP',    => 
            @highlight -1 
            zz.game.sound.play 'click'
        , [STATE.MENU, STATE.PAUSED]

        zz.game.key.on 'SPACE', => 
            @highlight 0
            zz.game.sound.play 'click'
        , [STATE.MENU, STATE.PAUSED]

        zz.game.key.on 'RETURN', => 
            @highlight 0
            zz.game.sound.play 'click'
        , [STATE.MENU, STATE.PAUSED]

        zz.game.key.on 'RETURN', =>
            zz.game.stop()
        , STATE.OVER

        zz.game.key.on 'ESC', =>
            zz.game.stop()
        , STATE.OVER

        zz.game.on 'start', =>

        zz.game.on 'pause', =>
            @showMenu 'pause'

        zz.game.on 'continue', =>
            @showMenu null

        zz.game.on 'stop', =>
            window.location = '/'

        zz.game.on 'state', (state)=>
            $('body').attr('class', '')
            $('body').addClass "state-#{state}"


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
        return unless id?
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

        return @highlight item.next() if index == 1 and item.next().length > 0 
        return @highlight item.prev() if index == -1 and item.prev().length > 0 

