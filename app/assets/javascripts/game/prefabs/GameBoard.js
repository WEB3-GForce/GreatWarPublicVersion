'use strict';

var GameBoard = function(game) {
    Phaser.Tilemap.call(this, game, 'tileset');

    this.addTilesetImage('tmw_desert_spacing', // tileset name, findable in the json 
			 'tmw_desert_spacing'
			);

    this.terrainLayer = this.createLayer('boardLayer'); // saved name of the layer
    this.initTiles();
};

GameBoard.prototype = Object.create(Phaser.Tilemap.prototype);
GameBoard.prototype.constructor = GameBoard;

GameBoard.prototype.initTiles = function() {
    for (var i = 0; i < this.width; i++) {
	for (var j = 0; j < this.height; j++) {
	    this.setTerrainTile(i, j);
	}
    }
}

GameBoard.prototype.setTerrainTile = function(x, y) {
    var oldTile = this.getTile(x, y, this.terrainLayer);
    this.layers[this.getLayer(this.terrainLayer)].data[y][x] =
	new TerrainTile(this.terrainLayer,
			oldTile.index, x, y,
			oldTile.width, oldTile.height);
}
