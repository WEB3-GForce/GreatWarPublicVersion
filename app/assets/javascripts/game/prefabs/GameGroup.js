'use strict';

var GameGroup = function(game, parent) {
    Phaser.Group.call(this, game, parent);

    this.gameBoard = new GameBoard(this.game);
    this.selected = null;
    this.unitGroup = this.game.add.group();

    this.marker = this.game.add.graphics();
    this.marker.lineStyle(2, 0x000000, 1);
    this.marker.drawRect(0, 0, 32, 32); // THIS IS HARDCODE

    this.ui = new UIGroup(this.game);
};

GameGroup.prototype = Object.create(Phaser.Group.prototype);
GameGroup.prototype.constructor = GameGroup;

GameGroup.prototype.update = function() {
    // moving the marker
    this.marker.x = this.gameBoard.highlightLayer.getTileX(this.game.input.activePointer.worldX) * 32;
    this.marker.y = this.gameBoard.highlightLayer.getTileY(this.game.input.activePointer.worldY) * 32;

    var currentTile = this.gameBoard.getTile(this.marker.x/32,
					     this.marker.y/32,
					     this.gameBoard.terrainLayer);

    this.ui.setTile(currentTile);

    if (this.game.input.mousePointer.targetObject)
	this.ui.setUnit(this.game.input.mousePointer.targetObject.sprite);
    else
	this.ui.setUnit(null);
}

GameGroup.prototype.onClick = function(targetObject) {
	if (targetObject) {
		this.selected = targetObject.sprite;
	}
	if (targetObject === null && this.selected) {
	    this.selected.moveTo(this.marker.x/32, this.marker.y/32);
	    this.selected = null;
	}
}

GameGroup.prototype.addUnit = function(x, y) {
	this.unitGroup.add(new Infantry(this.game, x, y));
}

