'use strict';

var HIGHLIGHT_TYPES = {
    blue: 51,
    red: 52,
    green: 53
};

var TILE_MAP  = {
    flatland: 30
};

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
    this.unhighlightAll();
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

GameBoard.prototype.isHighlighted = function(x, y) {
    return this.hasTile(x, y,
			this.highlightLayer);
}
GameBoard.prototype.highlight = function(x, y, type) {
    this.putTile(HIGHLIGHT_TYPES[type], x, y, this.highlightLayer);
}
GameBoard.prototype.unhighlight = function(x, y) {
    this.removeTile(x, y, this.highlightLayer);
}
GameBoard.prototype.unhighlightAll = function() {
    for (var i = 0; i < this.width; i++)
	for (var j = 0; j < this.height; j++)
	    this.unhighlight(i, j);
}
GameBoard.prototype.highlightRange = function(x, y, type, range) {
    if (range < 0 ||
	x < 0 || x >= this.width ||
	y < 0 || y >= this.height)
	return;
    this.highlight(x, y, type);
    this.highlightRange(x-1, y, type, range-1);
    this.highlightRange(x+1, y, type, range-1);
    this.highlightRange(x, y-1, type, range-1);
    this.highlightRange(x, y+1, type, range-1);
}

GameBoard.prototype.drawGrid = function() {
    this.grid = this.game.add.graphics();
    this.grid.lineStyle(1, 0x000000, 0.1);
    // draw vertical lines:
    for (var x = 0; x < this.width * this.game.constants.TILE_SIZE; x += this.game.constants.TILE_SIZE) {
    	this.grid.moveTo(x, 0);
    	this.grid.lineTo(x, this.height *  this.game.constants.TILE_SIZE)
    }
    // horizontal lines:
    for (var y = 0; y < this.height * this.game.constants.TILE_SIZE; y += this.game.constants.TILE_SIZE) {
    	this.grid.moveTo(0, y);
    	this.grid.lineTo(this.width * this.game.constants.TILE_SIZE, y);
    }
}

GameBoard.prototype.setTile = function(x, y, type) {
    this.putTile(TILE_MAP[type], x, y, this.terrainLayer);
}

GameBoard.prototype.terrainType = function(x, y) {
    this.getTile(x, y, this.terrainLayer);
}

GameBoard.prototype.terrainEffect = function(x, y) {
    return this.effects[this.terrainType(x, y)];
}
