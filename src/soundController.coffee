class SoundController extends Base

	sounds:
		click: 'click.wav'
		slide: 'slide.wav'
		match: 'match0.wav'

	constructor: ->
		for key,value of @sounds
			createjs.Sound.registerSound "assets/sounds/#{value}", key
		
	play: (sound, settings={})->
		createjs.Sound.play sound
			

class MusicController extends Base


	initialize: ->
		files = [ 
			{
				id: 'intro'
				src: 'intro.mp3'
			},
			{
				id: 'mid'
				src: 'mid.mp3'
			}
		]

		for f in files
			f.src = 'assets/music/' + f.src

		createjs.Sound.alternateExtensions = ["mp3"];
		createjs.Sound.registerSounds files

	constructor: ->
		@initialize()
		@current = null

		zz.game.on 'start', =>
			@current = createjs.Sound.play 'intro'
			@current.on 'complete', =>
				@current = createjs.Sound.play 'mid'
				@current.loop = true
				@current.volume = zz.game.settings.music

		zz.game.on 'pause', =>
			@current.volume = zz.game.settings.music / 3.0

		zz.game.on 'continue', =>
			@current.volume = zz.game.settings.music


class BoardSoundController extends Base

	events: [{
			on: 'match'
			sound: 'match'
			settings: 
				volume: 0.5
		},{
			on: 'cursorMove'
			sound: 'click'
			settings: 
				volume: 0.5
		},{
			on: 'swap'
			sound: 'slide'
			settings: 
				volume: 0.5
		}
	]

	constructor: (@board)->
		for event in @events
			@board.on event.on, ((e)=> =>
				createjs.Sound.play e.sound, e.settings
			)(event)

