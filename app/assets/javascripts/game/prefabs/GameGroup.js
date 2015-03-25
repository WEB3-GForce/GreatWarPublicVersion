'use strict';

var GameGroup = function(game, parent) {
    Phaser.Group.call(this, game, parent);

    this.gameBoard = new GameBoard(this.game);
    this.selected = null;
    this.unitGroup = this.game.add.group();
};

GameGroup.prototype = Object.create(Phaser.Group.prototype);
GameGroup.prototype.constructor = GameGroup;

GameGroup.prototype.onClick = function(targetObject) {
	if (targetObject) {
		this.selected = targetObject.sprite;
	}
	if (targetObject === null && this.selected) {
		this.selected.x = this.gameBoard.marker.x;
		this.selected.y = this.gameBoard.marker.y;

		this.selected = null;
	}
}

GameGroup.prototype.addUnit = function(x, y) {
	this.unitGroup.add(new Infantry(this.game, x, y));
}
