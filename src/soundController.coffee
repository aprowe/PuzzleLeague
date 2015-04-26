class SoundController extends Base

	sounds:
		click: 'click.wav'
		slide: 'slide.wav'
		match: 'match0.wav'

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

	@initialize: ()->
		for key,value of SoundController.prototype.sounds
			createjs.Sound.registerSound "assets/sounds/#{value}", key
		

	constructor: (@board)->
		for event in @events
			@board.on event.on, ((e)->
				console.log e
				-> createjs.Sound.play e.sound, e.settings
			)(event)
			

class MusicController extends Base


	@initialize: ->
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

	constructor: (@game)->
		@game.on 'start', =>
			intro = createjs.Sound.play 'intro'
			intro.on 'complete', =>
				mid = createjs.Sound.play 'mid'
				mid.loop = true


$ ->
	MusicController.initialize()
	SoundController.initialize()
		
