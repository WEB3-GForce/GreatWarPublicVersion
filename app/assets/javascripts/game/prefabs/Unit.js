'use strict';

var ORIENTATION_MAP = {
    down: 1,
    left: 4,
    right: 7,
    up: 10
}

var UNIT_MAP = {
    'artillery':
    {
        NAME: 'Artillery',
        IMAGE: 'trainer'
    },
    'command_bunker':
    {
        NAME: 'Bunker',
        IMAGE: 'trainer'
    },
    'infantry':
    {
        NAME: 'Infantry',
        IMAGE: 'trainer'
    },
    'machine_gun':
    {
        NAME: 'Machine Gun',
        IMAGE: 'trainer'
    },
}

var Unit = function(game, id, type, x, y, player, stats) {
    Phaser.Sprite.call(this, game,
		       x*game.constants.TILE_SIZE,
		       y*game.constants.TILE_SIZE,
		       UNIT_MAP[type].IMAGE, 1);

    this.id = id;
    this.orientation = "down";
    this.type = type;

    this.animations.add('walk-left', [3, 4, 5, 4]);
    this.animations.add('walk-right', [6, 7, 8, 7]);
    this.animations.add('walk-down', [0, 1, 2, 1]);
    this.animations.add('walk-up', [9, 10, 11, 10]);
    this.animations.add('melee-attack', [0, 3, 6, 9]);
    this.animations.add('ranged-attack', [1, 4, 7, 10]);

    this.inputEnabled = true;
    this.input.useHandCursor = true;

    this.stats = stats;
    this.player = player;
};

Unit.prototype = Object.create(Phaser.Sprite.prototype);
Unit.prototype.constructor = Unit;

Unit.prototype.isMine = function() {
    return this.player === this.game.constants.PLAYER_ID;
}

Unit.prototype.changeOrientation = function(orientation) {
    this.orientation = orientation;
    this.frame = ORIENTATION_MAP[orientation];
}

Unit.prototype.moveAdjacent = function(orientation) {
    this.orientation = orientation;
    var animation = "walk-" + orientation;
    this.animations.play(animation, 6, true);
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
    return this.game.add.tween(this).to(update, 200, Phaser.Easing.Linear.None, true);
}

Unit.prototype.stop = function() {
    this.animations.stop();
    this.frame = ORIENTATION_MAP[this.orientation];
}

Unit.prototype.moveTo = function(x, y, callback, callbackContext) {
    if (this.x/this.game.constants.TILE_SIZE < x) {
	this.moveAdjacent("right").onComplete.add(function() {
	    this.moveTo(x, y);
	}, this);
	return;
    }
    if (this.x/this.game.constants.TILE_SIZE > x) {
	this.moveAdjacent("left").onComplete.add(function() {
	    this.moveTo(x, y);
	}, this);
	return;
    }
    if (this.y/this.game.constants.TILE_SIZE < y) {
	this.moveAdjacent("down").onComplete.add(function() {
	    this.moveTo(x, y);
	}, this);
	return;
    }
    if (this.y/this.game.constants.TILE_SIZE > y) {
	this.moveAdjacent("up").onComplete.add(function() {
	    this.moveTo(x, y);
	}, this);
	return;
    }
    this.stop();
    if (callback)
	callback().bind(callbackContext);
}

// Unit.prototype.attack = function(unit, type) {
//     var givenDamage = type === 'melee' ? this.stats.ATK * 2 : this.stats.ATK;
//    var receivedDamage = type === 'melee' ? unit.stats.ATK * 2 : unit.stats.ATK;
//    if (!unit.damage(givenDamage))
//	this.damage(receivedDamage);
// }

// returns whether unit died
// Unit.prototype.damage = function(atk) {
//    this.stats.HP -= atk - this.stats.DEF;
//    if (this.stats.HP <= 0) {
//	this.destroy();
//	return true;
//    } else {
//	return false;
//    }
// }
