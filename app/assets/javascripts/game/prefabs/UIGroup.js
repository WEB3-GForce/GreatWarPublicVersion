'use strict';

var COLORS = {
    HEALTH: 0x7eb041,
    ENERGY: 0xfbb829,
    BUTTON: 0x556270,
    DEPLETED: 0xdadfe6,
    HOVER: 0x1693a5,
    RED: 0xFF4040
}

var UIGroup = function(game, parent) {
    Phaser.Group.call(this, game, parent);

    this.font = { font: "18px Helvetica", fill: "#ffffff" };
    this.smallerFont = { font: "14px Helvetica", fill: "#ffffff" };

    this.initActionMenu();
    this.initHealthDisplay();
    this.initUnitInfoUI();
    this.initPlayerInfoUI();
    this.initTileInfoUI();
    this.initTurnInfoUI();
};

UIGroup.prototype = Object.create(Phaser.Group.prototype);
UIGroup.prototype.constructor = UIGroup;

UIGroup.prototype.initPlayerInfoUI = function() {
    this.playerInfo = this.game.add.group();
    this.playerInfo.cameraOffset.x = 8;
    this.playerInfo.cameraOffset.y = 8;
    this.playerInfo.fixedToCamera = true;

    var width = 288;
    var height = 100;

    this.playerInfoGraphics = this.game.add.graphics(0, 0, this.playerInfo);
    this.playerInfoGraphics.beginFill(COLORS.BUTTON, 0.5);
    this.playerInfoGraphics.drawRect(0, 0, width, height);

    this.playerInfoGraphics.beginFill(COLORS.RED, 1);
    this.playerInfoGraphics.drawRect(64, 0, width - 64, 32);
    this.playerInfoGraphics.beginFill(COLORS.ENERGY, 1);
    this.playerInfoGraphics.drawRect(64, 32, width - 64, 32);

    this.playerName = this.game.add.bitmapText(72, 4, 'minecraftia',
					       "",
					       20,
					       this.playerInfo);

    this.turnCount = this.game.add.bitmapText(72, 36, 'minecraftia',
					      "",
					      20,
					      this.playerInfo);

    this.playerPortrait = this.game.add.sprite(0, 0, "", 0, this.playerInfo);
    this.playerPortrait.width = 64;
    this.playerPortrait.height = 64;

    this.endTurn = this.game.add.bitmapText(0, 66, 'minecraftia',
					    '         Press "z" to\n            End Turn',
					    12,
					    this.playerInfo);

    this.endGame = this.game.add.bitmapText(width/2, 66, 'minecraftia',
					    '        Press "q" to\n         Surrender',
					    12,
					    this.playerInfo);
}
UIGroup.prototype.setPlayer = function(playerId, player, turn) {
    if (player.faction == "red")
	this.playerInfoGraphics.beginFill(COLORS.RED, 1);
    else
	this.playerInfoGraphics.beginFill(COLORS.HOVER, 1);
    this.playerInfoGraphics.drawRect(64, 0, 288 - 64, 32);
    this.playerPortrait.loadTexture(playerId);
    this.playerPortrait.width = 64;
    this.playerPortrait.height = 64;
    this.playerName.text = player.name;
    this.turnCount.text = "Day " + turn;
}

UIGroup.prototype.checkPlayerInfoUIPosition = function(mouse) {
    if (mouse.x < 320) {
        if (this.portraitLeft)
	    this.playerInfo.cameraOffset.x = this.game.constants.CAMERA_WIDTH - 288 - 8;
        this.portraitLeft = false;
    } else {
        if (!this.portraitLeft)
	    this.playerInfo.cameraOffset.x = 8;
        this.portraitLeft = true;
    }
}

UIGroup.prototype.initTileInfoHelper = function(group, x) {
    var height = 160;
    var width = 96;
    group.cameraOffset.x = x;
    group.cameraOffset.y = this.game.constants.CAMERA_HEIGHT - height - 8;
    group.fixedToCamera = true;

    group.graphics = this.game.add.graphics(0, 0, group);
    group.graphics.beginFill(COLORS.BUTTON, 0.5);
    group.graphics.drawRect(0, 0, width, height);

    group.title = this.game.add.bitmapText(8, 8, 'minecraftia', '',
					   16,
					   group);
    group.tile = this.game.add.sprite(8, 40, 'terrain', 0, group);
    group.tile.alpha = 0.7;

    group.defense = this.game.add.bitmapText(7, 80, 'minecraftia',
					     'DEF:  0',
					     12, group);
    group.movementCost = this.game.add.bitmapText(7, 104, 'minecraftia',
						  'MOV:  1',
						  12, group);
}

UIGroup.prototype.initTileInfoUI = function() {
    this.tileInfoPrimary = this.game.add.group();
    this.tileInfoSecondary = this.game.add.group();
    this.initTileInfoHelper(this.tileInfoPrimary, 8);
    this.initTileInfoHelper(this.tileInfoSecondary, this.game.constants.CAMERA_WIDTH - 96 - 8);
    this.tileInfoSecondary.visible = false;
}

UIGroup.prototype.setTile = function(group, tile) {
    if (tile) {
	group.tile.frame = tile.index - 1;
	group.title.text = tile.name;
        var deftext = 'DEF:  ';
        if (tile.defense !== 'N/A') {
            deftext += '+';
        }
        var movtext = 'MOV:  ';
        if (tile.movementCost !== 'N/A') {
            movtext += 'x';
        }
        group.defense.text = deftext + tile.defense;
        group.movementCost.text = movtext  + tile.movementCost;
	group.visible = true;
    } else {
	group.visible = false;
    }
}
UIGroup.prototype.setPrimaryTile = function(tile) {
    this.setTile(this.tileInfoPrimary, tile);
}
UIGroup.prototype.setSecondaryTile = function(tile) {
    this.setTile(this.tileInfoSecondary, tile);

}

UIGroup.prototype.setUnit = function(group, tileGroup, unit, x1, x2) {
    if (unit) {
        group.unitType.text = unit.type[0].toUpperCase() + unit.type.replace('_', ' ').slice(1);
    	group.health.text = "HP:  " + unit.stats.health.current + "/" + unit.stats.health.max;
    	group.energy.text = "ENERGY:  " + unit.stats.energy.current + "/" + unit.stats.energy.max;
        group.attack.text = "ATTACK:  " + unit.stats.range.attack;

	group.unit.loadTexture(UNIT_MAP[unit.type].IMAGE + '-' + unit.faction);

    	group.visible = true;
	tileGroup.cameraOffset.x = x2;
    } else {
	group.visible = false;
        tileGroup.cameraOffset.x = x1;
    }
}
UIGroup.prototype.setPrimaryUnit = function(unit) {
    this.setUnit(this.unitInfoPrimary, this.tileInfoPrimary, unit, 8, 200);
}
UIGroup.prototype.setSecondaryUnit = function(unit) {
    this.setUnit(this.unitInfoSecondary, this.tileInfoSecondary, unit,
		 this.game.constants.CAMERA_WIDTH - 96 - 8, this.game.constants.CAMERA_WIDTH - 96 - 200);
}

UIGroup.prototype.initUnitInfoHelper = function(group, x) {
    var height = 160;
    var width = 192;
    group.cameraOffset.x = x;
    group.cameraOffset.y = this.game.constants.CAMERA_HEIGHT - height - 8;
    group.fixedToCamera = true;

    group.graphics = this.game.add.graphics(0, 0, group);
    group.graphics.beginFill(COLORS.BUTTON, 0.5);
    group.graphics.drawRect(0, 0, width, height);

    group.unitType = this.game.add.bitmapText(8, 8, 'minecraftia', '',
					      16,
					      group);
    group.unit = this.game.add.sprite(8, 40, 'artillery-red', 1, group);
    group.unit.alpha = 0.7;
    group.health = this.game.add.bitmapText(8, 80, 'minecraftia', '',
					    12,
					    group);
    group.attack = this.game.add.bitmapText(8, 104, 'minecraftia', '',
					    12,
					    group);
    group.energy = this.game.add.bitmapText(8, 128, 'minecraftia', '',
					    12,
					    group);
    group.visible = false;
}

UIGroup.prototype.initUnitInfoUI = function() {
    this.unitInfoPrimary = this.game.add.group();
    this.unitInfoSecondary = this.game.add.group();
    this.initUnitInfoHelper(this.unitInfoPrimary, 8);
    this.initUnitInfoHelper(this.unitInfoSecondary, this.game.constants.CAMERA_WIDTH - 192 - 8);
}

UIGroup.prototype.drawArc = function(graphics, x, y, r, start, end, stroke, color) {
    graphics.lineStyle(0);
    graphics.moveTo(x+r*Math.cos(start), y+r*Math.sin(start));
    graphics.lineStyle(stroke, color);
    graphics.arc(x, y, r, start, end);
    graphics.lineStyle(0);
}

UIGroup.prototype.arcTween = function(graphics, x, y, r, start, end, stroke, color, duration, easing) {
    var t = this.game.add.tween(graphics).to({}, duration, easing);
    t.onUpdateCallback(function(tween, fraction) {
	this.drawArc(graphics, x, y, r, start, start + fraction*(end - start), stroke, color);
    }, this);
    t.onComplete.add(function() {
	this.drawArc(graphics, x, y, r, start, end, stroke, color);
    }, this);
    return t;
}

UIGroup.prototype.initActionMenu = function() {
    this.actionMenu = this.game.add.group();
    this.actions = [];

    this.actionGraphics = this.game.add.graphics(0, 0, this.actionMenu);
    this.drawArc(this.actionGraphics, 0, 0, 44, -0.5*Math.PI, 1.5*Math.PI, 8, COLORS.BUTTON);
    this.drawArc(this.actionGraphics, 0, 0, 32, -0.5*Math.PI, 1.5*Math.PI, 16, COLORS.ENERGY);
    this.actionMenu.scale.x = 0;
    this.actionMenu.scale.y = 0;
    this.actionMenu.visible = false;
}

UIGroup.prototype.initHealthDisplay = function() {
    this.healthCircle = this.game.add.group();

    this.healthGraphics = this.game.add.graphics(0, 0, this.healthCircle);
    this.drawArc(this.healthGraphics, 0, 0, 44, -0.5*Math.PI, 1.5*Math.PI, 8, COLORS.BUTTON);
    this.drawArc(this.healthGraphics, 0, 0, 32, -0.5*Math.PI, 1.5*Math.PI, 16, COLORS.HEALTH);

    this.healthCircle.scale.x = 0;
    this.healthCircle.scale.y = 0;
    this.healthCircle.visible = false;
}

UIGroup.prototype.updateHealth = function(unit, newHealth, callback, callbackContext) {
    unit.getHit();
    // visual representation of remaining energy
    this.drawArc(this.healthGraphics, 0, 0, 32, -0.5*Math.PI, 1.5*Math.PI, 16, COLORS.HEALTH);
    this.drawArc(this.healthGraphics, 0, 0, 32,
		 -0.5*Math.PI, (-0.5 + 2*(1-unit.stats.health.current/unit.stats.health.max))*Math.PI,
		 16, COLORS.DEPLETED);

    this.healthCircle.x = unit.x + this.game.constants.TILE_SIZE/2;
    this.healthCircle.y = unit.y + this.game.constants.TILE_SIZE/2;
    this.healthCircle.visible = true;

    var showTween = this.game.add.tween(this.healthCircle.scale).to({x: 1, y: 1}, 200, Phaser.Easing.Quadratic.InOut);
    var healthTween = this.arcTween(this.healthGraphics, 0, 0, 32,
    				    (-0.5 + 2*(1-unit.stats.health.current/unit.stats.health.max))*Math.PI,
    				    (-0.5 + 2*(1-newHealth/unit.stats.health.max))*Math.PI,
    				    16, COLORS.DEPLETED, 300, Phaser.Easing.Quadratic.InOut);
    healthTween.onComplete.add(function() {
    	unit.stats.health.current = newHealth;
    }, this);
    var hideTween = this.game.add.tween(this.healthCircle.scale).to({x: 0, y: 0}, 200, Phaser.Easing.Quadratic.InOut, false, 300);
    hideTween.onComplete.add(function() {
    	this.healthCircle.visible = false;
	unit.stop();
	callback.bind(callbackContext)();
    }, this);

    showTween.chain(healthTween);
    healthTween.chain(hideTween);
    return showTween;
}

UIGroup.prototype.updateEnergy = function(unit, newEnergy, callback, callbackContext) {
    // visual representation of remaining energy
    this.drawArc(this.actionGraphics, 0, 0, 32, -0.5*Math.PI, 1.5*Math.PI, 16, COLORS.ENERGY);
    this.drawArc(this.actionGraphics, 0, 0, 32,
		 -0.5*Math.PI, (-0.5 + 2*(1-unit.stats.energy.current/unit.stats.energy.max))*Math.PI,
		 16, COLORS.DEPLETED);

    this.actionMenu.x = unit.x + this.game.constants.TILE_SIZE/2;
    this.actionMenu.y = unit.y + this.game.constants.TILE_SIZE/2;
    this.actionMenu.visible = true;

    var showTween = this.game.add.tween(this.actionMenu.scale).to({x: 1, y: 1}, 200, Phaser.Easing.Quadratic.InOut);
    var energyTween = this.arcTween(this.actionGraphics, 0, 0, 32,
    				    (-0.5 + 2*(1-unit.stats.energy.current/unit.stats.energy.max))*Math.PI,
    				    (-0.5 + 2*(1-newEnergy/unit.stats.energy.max))*Math.PI,
    				    16, COLORS.DEPLETED, 300, Phaser.Easing.Quadratic.InOut);
    energyTween.onComplete.add(function() {
    	unit.stats.energy.current = newEnergy;
    }, this);
    var hideTween = this.game.add.tween(this.actionMenu.scale).to({x: 0, y: 0}, 200, Phaser.Easing.Quadratic.InOut, false, 300);
    hideTween.onComplete.add(function() {
    	this.actionMenu.visible = false;
	callback.bind(callbackContext)();
    }, this);

    showTween.chain(energyTween);
    energyTween.chain(hideTween);
    return showTween;
}

UIGroup.prototype.showMenu = function(unit, actions) {
    for (var i = 0; i < actions.length; i++) {
	// add each button to an array of actions
	this.actions[i] = this.game.add.button(0, 0,
					       'action-' + actions[i].name,
					       function() {}, this,
					       0, 1
					      );
        this.actions[i].inputEnabled = true;
        this.actions[i].input.useHandCursor = true;
        this.actions[i].anchor.setTo(0.5, 0.5);
        this.actionMenu.add(this.actions[i]);
        var angle = 2*Math.PI / actions.length * i - Math.PI/2;
        var r = 80;
        this.actions[i].x = r*Math.cos(angle);
        this.actions[i].y = r*Math.sin(angle);
    }

    // visual representation of remaining energy
    this.drawArc(this.actionGraphics, 0, 0, 32, -0.5*Math.PI, 1.5*Math.PI, 16, COLORS.ENERGY);
    this.drawArc(this.actionGraphics, 0, 0, 32,
		 -0.5*Math.PI, (-0.5 + 2*(1-unit.stats.energy.current/unit.stats.energy.max))*Math.PI,
		 16, COLORS.DEPLETED);

    this.actionMenu.x = unit.x + this.game.constants.TILE_SIZE/2;
    this.actionMenu.y = unit.y + this.game.constants.TILE_SIZE/2;
    this.actionMenu.visible = true;
    return this.game.add.tween(this.actionMenu.scale).to({x: 1, y: 1}, 200, Phaser.Easing.Back.Out);
}

UIGroup.prototype.hideMenu = function() {
    var t = this.game.add.tween(this.actionMenu.scale).to({x: 0, y: 0}, 200, Phaser.Easing.Back.In);
    t.onComplete.add(function() {
	this.actionMenu.visible = false;
	for (var i = 0; i < this.actions.length; i++) {
	    this.actionMenu.remove(this.actions[i], true);
	}
	this.actions = [];
    }, this);
    return t;
}

UIGroup.prototype.menuVisible = function() {
    return this.actionMenu.visible;
}

UIGroup.prototype.initTurnInfoUI = function() {
    this.turnInfo = this.game.add.group();
    this.turnInfo.alpha = 0;
    this.turnInfo.fixedToCamera = true;

    var width = this.game.constants.CAMERA_WIDTH;
    var height = 100;

    this.turnInfoGraphics = this.game.add.graphics(0, 0, this.turnInfo);
    this.turnInfoGraphics.beginFill(COLORS.HOVER, 0.7);
    this.turnInfoGraphics.drawRect(0, this.game.constants.CAMERA_HEIGHT / 2 - height / 2,
				   width, height);

    this.turnText = this.game.add.bitmapText(width / 2, this.game.constants.CAMERA_HEIGHT / 2, 'minecraftia',
					     "",
					     20,
					     this.turnInfo);
    this.turnText.anchor.setTo(0.5, 0.5);
}
UIGroup.prototype.setTurnInfo = function(player) {
    this.turnText.text = player.name + "'s turn";
    this.turnInfoGraphics.clear();
    if (player.faction == "red")
	this.turnInfoGraphics.beginFill(COLORS.RED, 0.7);
    else
	this.turnInfoGraphics.beginFill(COLORS.HOVER, 0.7);
    this.turnInfoGraphics.drawRect(0, this.game.constants.CAMERA_HEIGHT / 2 - 50,
				   this.game.constants.CAMERA_WIDTH, 100);
    return this.game.add.tween(this.turnInfo).to({alpha: [0, 1, 1, 1, 1, 0]}, 1200);
}
