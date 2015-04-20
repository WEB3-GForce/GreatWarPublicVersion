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
};

Unit.prototype = Object.create(Phaser.Sprite.prototype);
Unit.prototype.constructor = Unit;

Unit.prototype.isMine = function() {
    return this.player === this.game.constants.PLAYER_ID;
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
