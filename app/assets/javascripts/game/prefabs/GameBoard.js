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
};

GameBoard.prototype = Object.create(Phaser.Tilemap.prototype);
GameBoard.prototype.constructor = GameBoard;
