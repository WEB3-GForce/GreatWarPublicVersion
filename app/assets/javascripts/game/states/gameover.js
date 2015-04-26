'use strict';

function GameOver() {
}

GameOver.prototype = {
    preload: function () {

    },
    create: function () {
	var style = { font: '65px Arial', fill: '#ffffff', align: 'center'};
	this.titleText = this.game.add.text(this.game.width / 2,100, 'Game Over!', style);
	this.titleText.anchor.setTo(0.5, 0.5);

	this.congratsText = this.game.add.text(this.game.width / 2, 200, this.game.endGameMessage, { font: '32px Arial', fill: '#ffffff', align: 'center'});
	this.congratsText.anchor.setTo(0.5, 0.5);

	// this.instructionText = this.game.add.text(this.game.width / 2, 300, 'Click To Play Again', { font: '16px Arial', fill: '#ffffff', align: 'center'});
	// this.instructionText.anchor.setTo(0.5, 0.5);
    },
    update: function () {
	if(this.game.input.activePointer.justPressed()) {
	    this.game.state.start('play');
	}
    }
};
