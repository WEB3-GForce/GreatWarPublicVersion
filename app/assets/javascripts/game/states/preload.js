'use strict';

function Preload() {
    this.asset = null;
    this.ready = false;
}

Preload.prototype = {
    preload: function() {
    	// pre-load bar from Yeoman example, will likely end up getting rid of this
		this.asset = this.add.sprite(this.width/2,this.height/2, 'preloader');
		this.asset.anchor.setTo(0.5, 0.5);
		this.load.onLoadComplete.addOnce(this.onLoadComplete, this);
		this.load.setPreloadSprite(this.asset);

		this.load.tilemap('tileset', '/assets/tiledTest.json', null, Phaser.Tilemap.TILED_JSON);
		this.load.image('tiles', '/assets/tmw_desert_spacing.png'); // tileset used
		this.load.image('infantry_right', '/assets/AW_infantry.png');
		this.load.image('infantry_left', '/assets/AW_infantry_mirror.png');

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
