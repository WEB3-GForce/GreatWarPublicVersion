'use strict';

//global variables
var game;

var width = 960;
var height = 960;
var cameraWidth = width/1.5;
var cameraHeight = width/1.5;
var play_camera;

window.onload = function () {

	game = new Phaser.Game(cameraWidth, cameraHeight, Phaser.AUTO, 'the-great-war');

	// Game States
	game.state.add('boot', Boot);
	game.state.add('gameover', GameOver);
	game.state.add('menu', Menu);
	game.state.add('play', Play);
	game.state.add('preload', Preload);

	game.state.start('boot');
};
