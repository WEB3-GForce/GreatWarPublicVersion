'use strict';

window.onload = function () {
    var constants = {
	WIDTH: 960,
	HEIGHT: 960,
	CAMERA_WIDTH: 640,
	CAMERA_HEIGHT: 640,
	TILE_SIZE: 32
    }

    var game = new Phaser.Game(constants.CAMERA_WIDTH, constants.CAMERA_HEIGHT, Phaser.AUTO, 'the-great-war');

    game.constants = constants;
    // Game States
    game.state.add('boot', Boot);
    game.state.add('gameover', GameOver);
    game.state.add('menu', Menu);
    game.state.add('play', Play);
    game.state.add('preload', Preload);

    game.state.start('boot');
};
