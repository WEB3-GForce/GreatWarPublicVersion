'use strict';

//global variables
var game;

var width = 960;
var height = 640;
var camera_width = width/1.5;

var tile_size = 32;

var game_group; // group of everything in the game that isn't UI
var UI_group; // group for UI elements that are fixed to the camera

var trench_x = 3; // arbitrary place to start drawing trenches
var trench_y = 3;

var play_camera;

window.onload = function () {

	game = new Phaser.Game(camera_width, camera_width, Phaser.AUTO, 'the-great-war');

	// Game States
	game.state.add('boot', Boot);
	game.state.add('gameover', GameOver);
	game.state.add('menu', Menu);
	game.state.add('play', Play);
	game.state.add('preload', Preload);

	game.state.start('boot');
};
