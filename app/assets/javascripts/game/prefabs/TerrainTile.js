'use strict';

var TerrainTile = function(layer, index, x, y, width, height) {
    Phaser.Tile.call(this, layer, index, x, y, width, height);
};

TerrainTile.prototype = Object.create(Phaser.Tile.prototype);
TerrainTile.prototype.constructor = TerrainTile;

