'use strict';

var GameGroup = function(game, parent) {
    Phaser.Group.call(this, game, parent);

    this.board = this.game.add.tilemap('tileset');
    this.board.addTilesetImage('tmw_desert_spacing', // tileset name, findable in the json 
			       'tmw_desert_spacing'
			      );
    this.board.addTilesetImage('units', // tileset name, findable in the json 
			       'units'
			      );

    this.backgroundLayer = this.board.createLayer('boardLayer'); // saved name of the layer
    this.add(this.backgroundLayer);

    this.unitLayer = this.board.createLayer('unitLayer'); // saved name of the layer
    this.add(this.unitLayer);
    
    this.board.putTile(49, 5, 5, this.unitLayer);
};

GameGroup.prototype = Object.create(Phaser.Group.prototype);
GameGroup.prototype.constructor = GameGroup;
