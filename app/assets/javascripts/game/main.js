'use strict';

var game;

// Use turbolinks events because Rails 4
$(document).on('page:change', function () {
    var constants = {
	WIDTH: 960,
	HEIGHT: 960,
	CAMERA_WIDTH: 640,
	CAMERA_HEIGHT: 640,
	TILE_SIZE: 32
    }

    // Because phaser doesn't actually check the id
    if (document.getElementById('the-great-war') === null)
	return;

    // Because turbolinks doesn't get rid of javascript variables on page change
    if (game) {
	game.dispatcher.bind("setChannel", function() {});
	game.dispatcher.unsubscribe(game.channel.name);
    }

    game = new Phaser.Game(constants.CAMERA_WIDTH, constants.CAMERA_HEIGHT, Phaser.CANVAS, document.getElementById('the-great-war'));

    game.constants = constants;
    // Game States
    game.state.add('boot', Boot);
    game.state.add('gameover', GameOver);
    game.state.add('menu', Menu);
    game.state.add('play', Play);
    game.state.add('preload', Preload);

    game.state.start('boot');
});
