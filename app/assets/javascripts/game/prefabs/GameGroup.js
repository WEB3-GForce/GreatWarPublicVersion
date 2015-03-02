'use strict';

var GameGroup = function(game, parent) {
    Phaser.Group.call(this, game, parent);

    this.board = this.game.add.tilemap('tileset');
    this.board.addTilesetImage('tmw_desert_spacing', // tileset name, findable in the json 
			  'tiles'
			 );

    this.backgroundLayer = this.board.createLayer('boardLayer'); // saved name of the layer
    this.add(this.backgroundLayer);
);

};

GameGroup.prototype = Object.create(Phaser.Group.prototype);
GameGroup.prototype.constructor = GameGroup;
