'use strict';

function Preload() {
    this.asset = null;
    this.ready = false;
}

Preload.prototype = {
    preload: function() {
	this.game.dispatcher = new WebSocketRails(window.location.host+'/websocket');

	// pre-load bar from Yeoman example, will likely end up getting rid of this
	this.asset = this.add.sprite(this.width/2,this.height/2, 'preloader');
	this.asset.anchor.setTo(0.5, 0.5);
	this.load.onLoadComplete.addOnce(this.onLoadComplete, this);
	this.load.setPreloadSprite(this.asset);

	this.load.tilemap('tileset', '/assets/tiledTest.json', null, Phaser.Tilemap.TILED_JSON);
	this.load.image('tmw_desert_spacing', '/assets/tmw_desert_spacing.png'); // tileset used
	this.load.image('fog', '/assets/fog.png');
	this.load.image('highlight', '/assets/highlight.png');

	this.load.image('generalPortrait', '/assets/generalPortrait.png');

	this.load.spritesheet('action-move', '/assets/move.png', 48, 48);
	this.load.spritesheet('action-melee', '/assets/melee.png', 48, 48);
	this.load.spritesheet('action-ranged', '/assets/ranged.png', 48, 48);

	this.load.spritesheet('trainer', '/assets/trainer.png',
			      this.game.constants.TILE_SIZE,
			      this.game.constants.TILE_SIZE);
	this.load.spritesheet('terrain', '/assets/tmw_desert_spacing.png',
			      this.game.constants.TILE_SIZE,
			      this.game.constants.TILE_SIZE,
			      -1, 1, 1);

	this.load.bitmapFont('minecraftia', 'assets/minecraftia.png', 'assets/minecraftia.fnt');
    },

    this.load.audio('ambience', ['/assets/sounds/background/ambience.mp3']);

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
