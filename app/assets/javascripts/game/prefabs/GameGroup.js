'use strict';

var GameGroup = function(game, parent) {
    Phaser.Group.call(this, game, parent);

    this.gameBoard = new GameBoard(this.game);
};

GameGroup.prototype = Object.create(Phaser.Group.prototype);
GameGroup.prototype.constructor = GameGroup;
