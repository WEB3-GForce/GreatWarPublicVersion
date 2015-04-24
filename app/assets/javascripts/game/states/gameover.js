'use strict';

function GameOver() {
}

GameOver.prototype = {
    preload: function () {

    },
    create: function () {
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
						 "Gameover",
						 16);
	this.subtitle.anchor.set(0.5, 0.5);
    },
    update: function () {

    }
};
