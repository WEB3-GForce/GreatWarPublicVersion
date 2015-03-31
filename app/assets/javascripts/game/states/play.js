'use strict';

function Play() {
}

Play.prototype = {
    create: function() {
	this.game.physics.startSystem(Phaser.Physics.ARCADE);

	this.yeoman = new Yeoman(this.game, this.game.width/2, this.game.height/2);
	this.game.add.existing(this.yeoman);

	this.yeoman.events.onInputDown.add(this.clickListener, this);
    },
    update: function() {

    },
    clickListener: function() {
	this.game.state.start('gameover');
    }
};
