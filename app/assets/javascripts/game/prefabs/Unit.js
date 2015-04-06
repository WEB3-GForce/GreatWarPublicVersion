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
        IMAGE: 'trainer',
        HP: 50,
        MAX_HP: 50,
        ATK: 100,
        DEF: 1,
        MOV: 1,
        RNG: 15,
        MEL: 0
    },
    'command_bunker': 
    {
        NAME: 'Bunker',
        IMAGE: 'trainer',
        HP: 10,
        MAX_HP: 10,
        ATK: 0,
        DEF: 0,
        MOV: 1,
        RNG: 0,
        MEL: 0
    },
    'infantry': 
    {
        NAME: 'Infantry',
        IMAGE: 'trainer',
        HP: 100,
        MAX_HP: 100,
        ATK: 30,
        DEF: 10,
        MOV: 2,
        RNG: 3,
        MEL: 1
    },
    'machine_gun':
    { 
        NAME: 'Machine Gun',
        IMAGE: 'trainer',
        HP: 100,
        MAX_HP: 100,
        ATK: 50,
        DEF: 5,
        MOV: 2,
        RNG: 4,
        MEL: 1
    },
}

var Unit = function(game, id, type, x, y, mine) {
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
    this.animations.add('attack', [0, 3, 6, 9]);

    this.inputEnabled = true;
    this.input.useHandCursor = true;

    this.stats = JSON.parse(JSON.stringify(UNIT_MAP[this.type]));

    this.mine = mine;
};

Unit.prototype = Object.create(Phaser.Sprite.prototype);
Unit.prototype.constructor = Unit;

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

Unit.prototype.moveTo = function(x, y) {
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
}

Unit.prototype.attack = function(unit, type) {
    var givenDamage = type === 'melee' ? this.stats.ATK * 2 : this.stats.ATK;
    var receivedDamage = type === 'melee' ? unit.stats.ATK * 2 : unit.stats.ATK;
    if (!unit.damage(givenDamage))
	this.damage(receivedDamage);
}

// returns whether unit died
Unit.prototype.damage = function(atk) {
    this.stats.HP -= atk - this.stats.DEF;
    if (this.stats.HP <= 0) {
	this.destroy();
	return true;
    } else {
	return false;
    }
}
