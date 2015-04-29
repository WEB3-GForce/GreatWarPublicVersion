'use strict';
var UNIT_MAP = {
    'artillery':
    {
        NAME: 'Artillery',
        IMAGE: 'artillery'
    },
    'command_bunker':
    {
        NAME: 'Bunker',
        IMAGE: 'command'
    },
    'infantry':
    {
        NAME: 'Infantry',
        IMAGE: 'infantry'
    },
    'machine_gun':
    {
        NAME: 'Machine Gun',
        IMAGE: 'machinegun'
    },
}

var Unit = function(game, id, type, x, y, player, stats, faction) {
    var image = UNIT_MAP[type].IMAGE + '-' + faction;

    Phaser.Sprite.call(this, game,
		       x*game.constants.TILE_SIZE,
		       y*game.constants.TILE_SIZE,
		       image, 0);

    this.animations.add('walk-right', [1, 2, 3, 2]);
    this.animations.add('walk-left', [4, 5, 6, 5]);
    this.animations.add('walk-down', [8, 9, 10, 9]);
    this.animations.add('walk-up', [11, 12, 13, 12]);
    this.animations.add('get-hit', [0, 7]);
    this.animations.add('dig-trench', [14, 0, 14, 0]);

    this.explosion = this.game.add.sprite(0, 0, 'explosion', 0);
    this.explosion.visible = false;
    this.explosion.animations.add('explode', [0,1,2,3,4,5,6,7,8,9]);

    this.id = id;
    if (faction === "blue") {
	this.orientation = "left";
	this.animations.add('melee-attack', [4, 5, 6, 5]);
	this.animations.add('ranged-attack', [4, 5, 6, 5]);
    } else {
	this.orientation = "right";
	this.animations.add('melee-attack', [1, 2, 3, 2]);
	this.animations.add('ranged-attack', [1, 2, 3, 2]);
    }
    this.type = type;
    this.faction = faction;

    this.inputEnabled = true;
    this.input.useHandCursor = true;

    this.stats = stats;
    this.player = player;

    this.disabled = false;
};

Unit.prototype = Object.create(Phaser.Sprite.prototype);
Unit.prototype.constructor = Unit;

Unit.prototype.isMine = function() {
    return this.player === this.game.constants.PLAYER_ID;
}

Unit.prototype.moveAdjacent = function(orientation) {
    this.orientation = orientation;
    var animation = "walk-" + orientation;
    this.animations.play(animation, 12, true);
    var update;
    switch (orientation) {
    case "down":
	update = {y: this.y + this.game.constants.TILE_SIZE};
	break;
    case "left":
	update = {x: this.x - this.game.constants.TILE_SIZE};
	break;
    case "right":
	update = {x: this.x + this.game.constants.TILE_SIZE};
	break;
    case "up":
	update = {y: this.y - this.game.constants.TILE_SIZE};
	break;
    }
    return this.game.add.tween(this).to(update, 150, Phaser.Easing.Linear.None, true);
}

Unit.prototype.stop = function() {
    this.animations.stop();
    this.frame = 0;
}

Unit.prototype.moveTo = function(x, y, stop, callback, callbackContext) {
    if (this.x/this.game.constants.TILE_SIZE < x) {
	this.moveAdjacent("right").onComplete.add(function() {
	    this.moveTo(x, y, stop, callback, callbackContext);
	}, this);
	return;
    }
    if (this.x/this.game.constants.TILE_SIZE > x) {
	this.moveAdjacent("left").onComplete.add(function() {
	    this.moveTo(x, y, stop, callback, callbackContext);
	}, this);
	return;
    }
    if (this.y/this.game.constants.TILE_SIZE < y) {
	this.moveAdjacent("down").onComplete.add(function() {
	    this.moveTo(x, y, stop, callback, callbackContext);
	}, this);
	return;
    }
    if (this.y/this.game.constants.TILE_SIZE > y) {
	this.moveAdjacent("up").onComplete.add(function() {
	    this.moveTo(x, y, stop, callback, callbackContext);
	}, this);
	return;
    }
    if (stop)
	this.stop();
    if (callback) {
	callback.bind(callbackContext)();
    }
}

Unit.prototype.attack = function(square, type) {
    var update = {};
    if (this.x/this.game.constants.TILE_SIZE < square.x)
	update.x = [this.x + this.game.constants.TILE_SIZE/2, this.x];
    else if (this.x/this.game.constants.TILE_SIZE > square.x)
	update.x = [this.x - this.game.constants.TILE_SIZE/2, this.x];
    if (this.y/this.game.constants.TILE_SIZE < square.y)
	update.y = [this.y + this.game.constants.TILE_SIZE/2, this.y];
    else if (this.y/this.game.constants.TILE_SIZE > square.y)
	update.y = [this.y - this.game.constants.TILE_SIZE/2, this.y];

    var tween = this.game.add.tween(this).to(update, 300);
    tween.interpolation(function(v, k){
        return Phaser.Math.linearInterpolation(v, k);
    });
    tween.onStart.add(function() {
	this.animations.play(type + "-attack", 16, true);
        if (type === 'ranged') {
            this.explosion.visible = true;
            this.explosion.x = square.x * this.game.constants.TILE_SIZE;
            this.explosion.y = square.y * this.game.constants.TILE_SIZE;
	    this.explosion.events.onAnimationComplete.addOnce(function() {
		this.explosion.visible = false;
	    }, this);
            this.explosion.animations.play('explode', 24, false);
        }
    }, this);
    tween.onComplete.add(function() {
	this.stop();
    }, this);
    return tween;
}

Unit.prototype.getHit = function() {
    this.animations.play("get-hit", 8, true);
}

Unit.prototype.digTrench = function(callback, callbackContext) {
    this.events.onAnimationComplete.addOnce(callback, callbackContext);
    this.animations.play("dig-trench", 8, false);
}

Unit.prototype.disable = function() {
    this.disabled = true;
    this.frame = 7;
}

Unit.prototype.enable = function() {
    this.disabled = false;
    this.frame = 0;
}
