'use strict';

var UIGroup = function(game, parent) {
    Phaser.Group.call(this, game, parent);

    this.font = { font: "18px Helvetica", fill: "#ffffff" };
    this.smallerFont = { font: "14px Helvetica", fill: "#ffffff" };

    // this.initTileInfoUI();
    this.initUnitInfoUI();
    this.initPlayerInfoUI();
    this.initActionMenu();
};

UIGroup.prototype = Object.create(Phaser.Group.prototype);
UIGroup.prototype.constructor = UIGroup;

UIGroup.prototype.initPlayerInfoUI = function() {
    this.playerInfo = this.game.add.group();
    this.playerInfo.x = 8;
    this.playerInfo.y = 8;
    this.playerInfo.fixedToCamera = true;

    var width = 256;
    var height = 72;

    this.playerInfoGraphics = this.game.add.graphics(0, 0, this.playerInfo);
    this.playerInfoGraphics.beginFill(0x000000, 0.5);
    this.playerInfoGraphics.drawRect(0, 0, width, height);

    this.playerNameBackground = this.game.add.graphics(72, 4, this.playerInfo);
    this.playerNameBackground.beginFill(0xFF0000, 0.5);
    this.playerNameBackground.drawRect(0, 0, width - 72 - 4, 36);

    this.playerName = this.game.add.text(76, 10,
        this.game.constants.PLAYER_NAME,
        this.font,
        this.playerInfo);

    this.turnNumber = this.game.add.text(84, 40,
        "Day: " + this.game.turnNumber,
        this.font,
        this.playerInfo);

    this.playerPortraitFrame = this.game.add.graphics(2, 3, this.playerInfo);
    this.playerPortraitFrame.beginFill(0x000000, 0.5);
    this.playerPortraitFrame.drawRect(0, 0, 66, 66);

    this.playerPortrait = this.game.add.sprite(44, 44, 'generalPortrait', this.playerInfo);
    this.playerPortrait.anchor.setTo(0.5, 0.5);
    this.playerPortrait.width = 64;
    this.playerPortrait.height = 64;
    this.playerPortrait.fixedToCamera = true;
}

UIGroup.prototype.initTileInfoUI = function() {
    this.tileInfo = this.game.add.group();
    this.tileInfo.x = 8;
    this.tileInfo.y = 8;
    this.tileInfo.fixedToCamera = true;

    this.tileGraphics = this.game.add.graphics(0, 0, this.tileInfo);
    this.tileGraphics.beginFill(0x000000, 0.3);
    this.tileGraphics.drawRect(0, 0, 128, 48);

    this.currentTile = this.game.add.sprite(8, 8, 'terrain', 0, this.tileInfo);
    this.currentTile.alpha = 0.5;

    this.tileTitle = this.game.add.text(48, 24, "test",
                    this.font,
                    this.tileInfo);
    this.tileTitle.anchor.setTo(0, 0.5);
}

UIGroup.prototype.initUnitInfoUI = function() {
    this.unitInfo = this.game.add.group();
    this.unitInfo.x = 8;
    this.unitInfo.y = this.game.height - 128 - 8;
    this.unitInfo.fixedToCamera = true;

    this.unitGraphics = this.game.add.graphics(0, 0, this.unitInfo);
    this.unitGraphics.beginFill(0x000000, 0.3);
    this.unitGraphics.drawRect(0, 0, 128, 128);

    this.unitType = this.game.add.text(8, 8, "",
                       this.font,
                       this.unitInfo);

    this.unitImage = this.game.add.sprite(64, this.game.height - 120,
                       "trainer", 0,
                       this.unitInfo);
    this.unitImage.fixedToCamera = true;
    this.unitImage.alpha = 0.5;

    this.unitHealth = this.game.add.text(8, 64, "",
                       this.smallerFont,
                       this.unitInfo);
    this.unitAttack = this.game.add.text(8, 88, "",
                       this.smallerFont,
                       this.unitInfo);
    this.unitEnergy = this.game.add.text(8, 112, "",
                       this.smallerFont,
                       this.unitInfo);
    this.unitInfo.visible = false;
}

UIGroup.prototype.initActionMenu = function() {
    this.actionMenu = this.game.add.group();
    var actions = ['move', 'ranged', 'melee'];
    for (var i = 0; i < actions.length; i++) {
        var name = actions[i] + 'Button';
        this[name] = this.game.add.button(0, 0, 'action-' + actions[i]);
        this[name].inputEnabled = true;
        this[name].input.useHandCursor = true;
        this[name].anchor.setTo(0.5, 0.5);
        this.actionMenu.add(this[name]);
        var angle = 2*Math.PI / actions.length * i - Math.PI/2;
        var r = 48;
        this[name].x = r*Math.cos(angle);
        this[name].y = r*Math.sin(angle);
    }
    this.actionMenu.alpha = 0.7;
    this.actionMenu.visible = false;
}

UIGroup.prototype.setTile = function(tile) {
    // this.currentTile.frame = tile.index - 1;
    // this.tileTitle.text = "tile #" + tile.index;
}

UIGroup.prototype.setUnit = function(unit) {
    if (unit) {
        this.unitType.text = unit.type[0].toUpperCase() + unit.type.slice(1);
    	this.unitHealth.text = "HP: " + unit.stats.health.current + "/" + unit.stats.health.max;
    	this.unitEnergy.text = "ENERGY: " + unit.stats.energy.current + "/" + unit.stats.energy.max;
        this.unitAttack.text = "ATTACK: " + unit.stats.range.attack;
    	this.unitInfo.visible = true;
    } else {
	    this.unitInfo.visible = false;
    }
}

UIGroup.prototype.showMenu = function(unit) {
    this.actionMenu.x = unit.x + this.game.constants.TILE_SIZE/2;
    this.actionMenu.y = unit.y + this.game.constants.TILE_SIZE/2;
    this.actionMenu.visible = true;
}

UIGroup.prototype.hideMenu = function() {
    this.actionMenu.visible = false;
}

