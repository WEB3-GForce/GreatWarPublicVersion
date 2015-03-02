'use strict';

//global variables
var game;
window.onload = function () {
  game = new Phaser.Game(800, 600, Phaser.AUTO, 'the-great-war');

  // Game States
  game.state.add('boot', Boot);
  game.state.add('gameover', GameOver);
  game.state.add('menu', Menu);
  game.state.add('play', Play);
  game.state.add('preload', Preload);

  game.state.start('boot');
};
