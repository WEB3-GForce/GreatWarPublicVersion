'use strict';

/**
 * Preload state. Loads assets.
 * @constructor
 */
function Preload() {
    this.asset = null;
    this.ready = false;
}

Preload.prototype = {

    /**
     * Initialize the websocket dispatcher.
     * Load all assets.
     */
    preload: function() {
	this.game.dispatcher = new WebSocketRails(window.location.host+'/websocket');

	this.asset = this.add.sprite(this.game.width/2,this.game.height/2, 'preloader');
	this.asset.anchor.setTo(0.5, 0.5);
	this.load.onLoadComplete.addOnce(this.onLoadComplete, this);
	this.load.setPreloadSprite(this.asset);

	this.load.tilemap('tileset', '/assets/demo.json', null, Phaser.Tilemap.TILED_JSON);
	this.load.image('fe', '/assets/fe.png'); // tileset used
	this.load.image('fog', '/assets/fog.png');
	this.load.image('highlight', '/assets/highlight.png');

	this.load.image('lobby', '/assets/lobby.jpg');

	this.load.spritesheet('action-move', '/assets/move.png', 48, 48);
	this.load.spritesheet('action-melee', '/assets/melee.png', 48, 48);
	this.load.spritesheet('action-ranged', '/assets/ranged.png', 48, 48);
	this.load.spritesheet('action-trench', '/assets/trench.png', 48, 48);

	this.load.spritesheet('explosion', '/assets/explosion.png', 32, 32);

	var types = ['infantry', 'machinegun', 'artillery', 'command'];
	var colors = ['red', 'blue'];
	for (var i = 0; i < types.length; i++) {
            for (var j = 0; j < colors.length; j++) {
		var str = types[i] + '-' + colors[j];
		this.load.spritesheet(str, '/assets/'+str+'.png',
				      this.game.constants.TILE_SIZE,
				      this.game.constants.TILE_SIZE);
            }
	}

	this.load.spritesheet('terrain', '/assets/fe.png',
			      this.game.constants.TILE_SIZE,
			      this.game.constants.TILE_SIZE);

	this.load.bitmapFont('minecraftia', 'assets/minecraftia.png', 'assets/minecraftia.fnt');

	this.load.audio('ambience', ['assets/ambience.mp3']);

	//+ Jonas Raoni Soares Silva
	//@ http://jsfromhell.com/array/shuffle [v1.0]
	var shuffle = function(o){ //v1.0
            for(var j, x, i = o.length; i; j = parseInt(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
            return o;
	};

	var order = shuffle([1, 2, 3]);
	for (var i = 0; i < 3; i++) {
            this.load.audio('music-'+i, 'assets/music-'+order[i]+'.mp3');
	}

	this.load.audio('artillery-death', 'assets/artillery-death.mp3');
	this.load.audio('blast-1', 'assets/blast-1.mp3');
	this.load.audio('blast-2', 'assets/blast-2.mp3');
	this.load.audio('die-1', 'assets/die-1.mp3');
	this.load.audio('die-2', 'assets/die-2.mp3');
	this.load.audio('grenade', 'assets/grenade.mp3');
	this.load.audio('hurt', 'assets/hurt.mp3');
	this.load.audio('machine-gun-1', 'assets/machine-gun-1.mp3');
	this.load.audio('machine-gun-2', 'assets/machine-gun-2.mp3');
	this.load.audio('marching', 'assets/marching.mp3');
	this.load.audio('pistol', 'assets/pistol.mp3');
	this.load.audio('rifle', 'assets/rifle.mp3');
	this.load.audio('shot-1', 'assets/shot-1.mp3');
	this.load.audio('shot-2', 'assets/shot-2.mp3');
	this.load.audio('shotgun', 'assets/shotgun.mp3');
	this.load.audio('sniper', 'assets/sniper.mp3');
	this.load.audio('truck-driving', 'assets/truck-driving.mp3');
    },

    create: function() {
	this.asset.cropEnabled = false;
    },

    /**
     * Start the menu state once everything is loaded.
     */
    update: function() {
	if(!!this.ready) {
            this.game.state.start('menu'); // toggle between menu and play for testing
	}
    },

    onLoadComplete: function() {
	this.ready = true;
    }
};
