'use strict';

/**
 * Gameover state. Displays the game outcome.
 * @constructor
 */
function GameOver() {
}

GameOver.prototype = {
    init: function(text) {
	this.text = text;
    },
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

	this.subtitle = this.game.add.bitmapText(this.game.constants.CAMERA_WIDTH / 2, 240,
						 'minecraftia',
						 this.text,
						 20);
	this.subtitle.anchor.set(0.5, 0.5);
	this.subtitle.align = 'center';

	this.instructions = this.game.add.bitmapText(this.game.constants.CAMERA_WIDTH / 2, 320,
						     'minecraftia',
						     "Go back to the lobby if\nyou want to join or\ncreate a new game.",
						     16);
	this.instructions.anchor.set(0.5, 0.5);
	this.instructions.align = 'center';
    },
    update: function () {

    }
};
