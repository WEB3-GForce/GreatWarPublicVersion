'use strict';

var GameGroup = function(game, parent) {
    Phaser.Group.call(this, game, parent);

    this.board = this.game.add.tilemap('tileset');
    this.board.addTilesetImage('tmw_desert_spacing', // tileset name, findable in the json 
			  'tiles'
			 );

    this.backgroundLayer = this.board.createLayer('boardLayer'); // saved name of the layer
    this.add(this.backgroundLayer);

    this.backgroundLayer.tileWidth = 
    	this.backgroundLayer.layer.widthInPixels / this.backgroundLayer.layer.width;
    this.backgroundLayer.tileHeight =
    	this.backgroundLayer.layer.heightInPixels / this.backgroundLayer.layer.height;

    // draw the grid lines on the board
    this.drawLines();
};

GameGroup.prototype = Object.create(Phaser.Group.prototype);
GameGroup.prototype.constructor = GameGroup;

GameGroup.prototype.drawLines = function() {
	// draw vertical lines
	for (var x = 0; x < this.backgroundLayer.layer.widthInPixels; x++) {
		var verticalLine = game.add.graphics(0, 0);
	    verticalLine.beginFill(0xffffff);
	    verticalLine.lineStyle(1, 0xffffff, 1);
	    verticalLine.moveTo(x * this.backgroundLayer.tileWidth, 0);
	    verticalLine.lineTo(
	    	x * this.backgroundLayer.tileWidth, 
	    	this.backgroundLayer.layer.heightInPixels
	    );
	    verticalLine.endFill();
	}
	// draw horizontal lines
	for (var y = 0; y < this.backgroundLayer.layer.heightInPixels; y++) {
		var horizontalLine = game.add.graphics(0, 0);
	    horizontalLine.beginFill(0xffffff);
	    horizontalLine.lineStyle(1, 0xffffff, 1);
	    horizontalLine.moveTo(0, y * this.backgroundLayer.tileHeight);
	    horizontalLine.lineTo(
	    	this.backgroundLayer.layer.widthInPixels, 
	    	y * this.backgroundLayer.tileHeight
	    );
	    horizontalLine.endFill();
	}
	
};