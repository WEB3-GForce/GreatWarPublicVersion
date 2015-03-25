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

    this.drawGrid();

    this.marker = this.game.add.graphics();
    this.marker.lineStyle(2, 0x000000, 1);
    this.marker.drawRect(0, 0, 32, 32); // THIS IS HARDCODED
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

GameBoard.prototype.update = function() {
    // moving the marker
    this.marker.x = this.highlightLayer.getTileX(this.game.input.activePointer.worldX) * 32;
    this.marker.y = this.highlightLayer.getTileY(this.game.input.activePointer.worldY) * 32;
}

GameBoard.prototype.onClick = function() {
    this.highlight(this.marker.x/32, this.marker.y/32);
}

GameBoard.prototype.drawGrid = function() {
    this.grid = this.game.add.graphics();
    this.grid.lineStyle(1, 0xA9A9A9, 0.5);
    // draw vertical lines:
    for (var x = 0; x < this.width * 32; x += 32) {
    	this.grid.moveTo(x, 0);
    	this.grid.lineTo(x, this.height * 32)
    }
    // horizontal lines:
    for (var y = 0; y < this.height * 32; y += 32) {
    	this.grid.moveTo(0, y);
    	this.grid.lineTo(this.width * 32, y);
    }
}
