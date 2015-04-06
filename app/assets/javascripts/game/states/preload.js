'use strict';

function Preload() {
    this.asset = null;
    this.ready = false;
}

Preload.prototype = {
    preload: function() {
	this.game.dispatcher = new WebSocketRails('localhost:3000/websocket');

    	// pre-load bar from Yeoman example, will likely end up getting rid of this
	this.asset = this.add.sprite(this.width/2,this.height/2, 'preloader');
	this.asset.anchor.setTo(0.5, 0.5);
	this.load.onLoadComplete.addOnce(this.onLoadComplete, this);
	this.load.setPreloadSprite(this.asset);

	this.load.tilemap('tileset', '/assets/tiledTest.json', null, Phaser.Tilemap.TILED_JSON);
	this.load.image('tmw_desert_spacing', '/assets/tmw_desert_spacing.png'); // tileset used
	this.load.image('fog', '/assets/fog.png');
	this.load.image('highlight', '/assets/highlight.png');

	this.load.image('unit', '/assets/infantry.png');

	this.load.image('action-move', '/assets/move.png');
	this.load.image('action-melee', '/assets/melee.png');
	this.load.image('action-ranged', '/assets/ranged.png');

	this.load.spritesheet('trainer', '/assets/trainer.png',
			      this.game.constants.TILE_SIZE,
			      this.game.constants.TILE_SIZE);
	this.load.spritesheet('terrain', '/assets/tmw_desert_spacing.png',
			      this.game.constants.TILE_SIZE,
			      this.game.constants.TILE_SIZE,
			      -1, 1, 1);
    },
    create: function() {
	this.asset.cropEnabled = false;
    },
    update: function() {
	if(!!this.ready) {
	    this.game.state.start('play'); // toggle between menu and play for testing
	}
    },
    onLoadComplete: function() {
	this.ready = true;
    }
};
