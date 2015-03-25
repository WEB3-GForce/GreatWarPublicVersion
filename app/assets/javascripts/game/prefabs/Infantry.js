'use strict';

var ORIENTATION_MAP = {
    down: 1,
    left: 4,
    right: 7,
    up: 10
}

var Infantry = function(game, x, y) {
    Phaser.Sprite.call(this, game, x*32, y*32, 'trainer', 1);
    this.orientation = "down";

    this.animations.add('walk-left', [3, 4, 5, 4]);
    this.animations.add('walk-right', [6, 7, 8, 7]);
    this.animations.add('walk-down', [0, 1, 2, 1]);
    this.animations.add('walk-up', [9, 10, 11, 10]);

    this.inputEnabled = true;
    this.input.useHandCursor = true;
};

Infantry.prototype = Object.create(Phaser.Sprite.prototype);
Infantry.prototype.constructor = Infantry;

Infantry.prototype.changeOrientation = function(orientation) {
    this.orientation = orientation;
    this.frame = ORIENTATION_MAP[orientation];
}

Infantry.prototype.moveAdjacent = function(orientation) {
    this.orientation = orientation;
    this.animations.play("walk-" + orientation, 5, true);
    var update;
    switch (orientation) {
    case "down":
		update = {y: this.y + 32};
		break;
    case "left":
		update = {x: this.x - 32};
		break;
    case "right":
		update = {x: this.x + 32};
		break;
    case "up":
		update = {y: this.y - 32};
		break;
    }
    return this.game.add.tween(this).to(update, 500, Phaser.Easing.Linear.None);
}

Infantry.prototype.stop = function() {
    this.animations.stop();
    this.frame = ORIENTATION_MAP[this.orientation];
}

Infantry.prototype.moveTo = function(x, y) {
	var tweens = [];
	if (this.x/32 < x) {
		for (var pos = 0; pos < x - this.x/32; pos++) {
			tweens.push(this.moveAdjacent("right"));
		}
	}
	if (this.x/32 > x) {
		for (var pos = 0; pos < this.x/32 - x; pos++) {
			tweens.push(this.moveAdjacent("left"));
		}
	}

	if (this.y/32 < y) {
		for (var pos = 0; pos < y - this.y/32; pos++) {
			tweens.push(this.moveAdjacent("down"));
		}
	}
	if (this.y/32 > y) {
		for (var pos = 0; pos < this.y/32 - y; pos++) {
			tweens.push(this.moveAdjacent("up"));
		}
	}
	console.log(tweens);
	if (tweens.length > 0) {
		tweens[0].chain.apply(tweens.slice(1));
		tweens[0].start();
		tweens[0].onComplete.add(function() {
			this.stop();
		}, this);
	}

	// this.selected.moveAdjacent("right").onComplete.add(function() {
	// 		this.selected.moveAdjacent("right");
	// 		this.selected = null;
	// }, this);
}








