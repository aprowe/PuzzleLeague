var prompt = require('prompt');


var puzzle = require('./puzzle.js');

board = puzzle.game.boards[0]

prompt.start();

fn = function() {
prompt.get(['move'], function (err, result) {
	var x = {
		a: function(){
			board.cursor.x--
		},

		d: function(){
			board.cursor.x++
		},
		s: function(){
			board.cursor.y--
		},
		w: function(){
			board.cursor.y++
		},

		'': function(){
			board.swap()
			board.update()
			board.update()
			board.update()
		},
	}[result.move]

	if (typeof x !== 'undefined'){
		x()
	}
	console.log(board.render())

	fn()

});

};

console.log(board.render())
fn()
board.update()
board.update()
board.update()
board.update()
board.update()
