'use strict';

function Menu() {
}

Menu.prototype = {
    preload: function() {

    },
    create: function() {
	this.numPlayers = 0;

    	this.game.dispatcher.bind('setChannel', (function(data) {
    	    this.game.channel = this.game.dispatcher.subscribe(data.channel);
	    
	    this.game.channel.bind('initGame', (function(data) {
		this.game.state.start('play');
    	    }).bind(this));

	    this.game.channel.bind('gameover', (function(data) {
		this.game.state.start('gameover');
    	    }).bind(this));

	    this.game.channel.bind('userJoined', (function(data) {
		this.addPlayer(data.name);
	    }).bind(this));

            this.game.dispatcher.trigger('get_game', {});

	    this.addPlayer(data.name);
    	}).bind(this));

	this.game.dispatcher.trigger('get_channel', {});

	this.game.add.image(0, 0, 'lobby');

	this.graphics = this.game.add.graphics(0, 0);
	this.graphics.beginFill(COLORS.SLATE, 0.7);
	this.graphics.drawRect(80, 80, 480, 480);

	this.title = this.game.add.bitmapText(this.game.constants.CAMERA_WIDTH / 2, 160,
					      'minecraftia',
					      "THE GREAT WAR",
					      32);
	this.title.anchor.set(0.5, 0.5);
	this.subtitle = this.game.add.bitmapText(this.game.constants.CAMERA_WIDTH / 2, 200,
						 'minecraftia',
						 "Waiting for players",
						 16);
	this.subtitle.anchor.set(0.5, 0.5);
    },

    update: function() {
    },

    addPlayer: function(name) {
	this.numPlayers++;
	this.graphics.beginFill(COLORS.BUTTON, 0.7);
	var x = 120;
	var y = 160 + this.numPlayers*100;
	this.graphics.drawRoundedRect(x, y, 400, 80, 10);
	this.game.add.bitmapText(x + 40, y + 40,
				 'minecraftia',
				 name,
				 16)
	    .anchor.set(0, 0.5);
    }
};
