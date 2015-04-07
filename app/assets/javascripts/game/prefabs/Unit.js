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
        HP: 12,
        MAX_HP: 12,
	MOVEMENT_COST: 6,
        ATTACK_COST: 6,
	MELEE_COST: 6,
	ATTACK_DAMAGE: 10,
	MELEE_DAMAGE: 0,
        RANGE: 10,
        VISION: 2,
	ENERGY: 6
    },
    'command_bunker': 
    {
        NAME: 'Bunker',
        IMAGE: 'trainer',
        HP: 12,
        MAX_HP: 12,
	MOVEMENT_COST: 1,
        ATTACK_COST: 0,
	MELEE_COST: 0,
	ATTACK_DAMAGE: 0,
	MELEE_DAMAGE: 0,
        RANGE: 0,
        VISION: 1,
	ENERGY: 0
    },
    'infantry': 
    {
        NAME: 'Infantry',
        IMAGE: 'trainer',
        HP: 12,
        MAX_HP: 12,
	MOVEMENT_COST: 2,
        ATTACK_COST: 4,
	MELEE_COST: 4,
	ATTACK_DAMAGE: 6,
	MELEE_DAMAGE: 6,
        RANGE: 2,
        VISION: 4,
	ENERGY: 6
    },
    'machine_gun':
    { 
        NAME: 'Machine Gun',
        IMAGE: 'trainer',
        HP: 12,
        MAX_HP: 12,
	MOVEMENT_COST: 3,
        ATTACK_COST: 2,
	MELEE_COST: 6,
	ATTACK_DAMAGE: 4,
	MELEE_DAMAGE: 6,
        RANGE: 3,
        VISION: 3,
	ENERGY: 6
    },
}

var Unit = function(game, type, x, y, mine) {
    Phaser.Sprite.call(this, game, x*32, y*32, UNIT_MAP[type].IMAGE, 1);
    this.orientation = "down";
    this.type = type;

    this.animations.add('walk-left', [3, 4, 5, 4]);
    this.animations.add('walk-right', [6, 7, 8, 7]);
    this.animations.add('walk-down', [0, 1, 2, 1]);
    this.animations.add('walk-up', [9, 10, 11, 10]);

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
    return this.game.add.tween(this).to(update, 200, Phaser.Easing.Linear.None, true);
}

Unit.prototype.stop = function() {
    this.animations.stop();
    this.frame = ORIENTATION_MAP[this.orientation];
}

Unit.prototype.moveTo = function(x, y) {
    if (this.x/32 < x) {
	this.moveAdjacent("right").onComplete.add(function() {
	    this.moveTo(x, y);
	}, this);
	return;
    }
    if (this.x/32 > x) {
	this.moveAdjacent("left").onComplete.add(function() {
	    this.moveTo(x, y);
	}, this);
	return;
    }
    if (this.y/32 < y) {
	this.moveAdjacent("down").onComplete.add(function() {
	    this.moveTo(x, y);
	}, this);
	return;
    }
    if (this.y/32 > y) {
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
