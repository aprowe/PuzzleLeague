class SoundController extends Base

	sounds:
		click: 'click.wav'
		swoosh: 'swoosh.mp3'
		activate: 'activate.wav'

	events:
		match: 'activate'
		cursorMove: 'click'
		swap: 'swoosh'

	constructor: (@board)->
		for key,value of @sounds
			createjs.Sound.registerSound "assets/sounds/#{value}", key

		for key, value of @events
			@board.on key, ((id)->
				-> createjs.Sound.play id
			)(value)
			
