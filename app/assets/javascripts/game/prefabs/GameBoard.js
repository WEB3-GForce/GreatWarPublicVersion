'use strict';

var GameBoard = function(game) {
    Phaser.Tilemap.call(this, game, 'tileset');

    this.addTilesetImage('tmw_desert_spacing', // tileset name, findable in the json 
			 'tmw_desert_spacing'
			);
    this.addTilesetImage('fog', 'fog');
    this.addTilesetImage('highlight', 'highlight');

    this.terrainLayer = this.createLayer('terrainLayer'); // saved name of the layer
    this.fogLayer = this.createLayer('fogLayer');
    this.highlightLayer = this.createLayer('highlightLayer');

    this.marker = this.game.add.graphics();
    this.marker.lineStyle(2, 0x000000, 1);
    this.marker.drawRect(0, 0, 32, 32);

};

GameBoard.prototype = Object.create(Phaser.Tilemap.prototype);
GameBoard.prototype.constructor = GameBoard;

GameBoard.prototype.addFog = function(x, y) {
	var fogIndex = 50; // this is the index into the tilesheet and is a
					   // terrible way to do this
	this.putTile(fogIndex, x, y, this.fogLayer);
}
GameBoard.prototype.revealFog = function(x, y) {
	this.removeTile(x, y, this.fogLayer);
}

GameBoard.prototype.highlight = function(x, y) {
	var highlightIndex = 51; 
	this.putTile(highlightIndex, x, y, this.highlightLayer);
}
GameBoard.prototype.unhighlight = function(x, y) {
	this.removeTile(x, y, this.highlightLayer);
}

GameBoard.prototype.updateMarker = function() {
	this.marker.x = this.highlightLayer.getTileX(this.game.input.activePointer.worldX) * 32;
    this.marker.y = this.highlightLayer.getTileY(this.game.input.activePointer.worldY) * 32;
}