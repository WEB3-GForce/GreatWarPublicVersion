'use strict';

var UIGroup = function(game, parent) {
    Phaser.Group.call(this, game, parent);

    this.font = { font: "18px Helvetica", fill: "#ffffff" };
    this.smallerFont = { font: "14px Helvetica", fill: "#ffffff" };
    
    this.initTileInfoUI();
    this.initUnitInfoUI();
    this.initActionMenu(); 
};

UIGroup.prototype = Object.create(Phaser.Group.prototype);
UIGroup.prototype.constructor = UIGroup;

UIGroup.prototype.setTile = function(tile) {
    this.currentTile.frame = tile.index - 1;
    this.tileTitle.text = "tile #" + tile.index;
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
    this.unitInfo.x = this.game.width - 128 - 8;
    this.unitInfo.y = 8;
    this.unitInfo.fixedToCamera = true;

    this.unitGraphics = this.game.add.graphics(0, 0, this.unitInfo);
    this.unitGraphics.beginFill(0x000000, 0.3);
    this.unitGraphics.drawRect(0, 0, 128, 128);

    this.unitType = this.game.add.text(8, 8, "Infantry",
                       this.font,
                       this.unitInfo);
    this.unitHP = this.game.add.text(8, 40, "",
                       this.smallerFont,
                       this.unitInfo);
    this.unitATK = this.game.add.text(8, 64, "",
                       this.smallerFont,
                       this.unitInfo);
    this.unitDEF = this.game.add.text(8, 88, "",
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

UIGroup.prototype.setUnit = function(unit) {
    if (unit) {
    	this.unitHP.text = "HP: " + unit.stats.HP + "/" + unit.stats.MAX_HP;
    	this.unitATK.text = "ATK: " + unit.stats.ATK;
    	this.unitDEF.text = "DEF: " + unit.stats.DEF;
    	this.unitInfo.visible = true;
    } else {
	    this.unitInfo.visible = false;
    }
}

UIGroup.prototype.showMenu = function(unit) {
    this.actionMenu.x = unit.x + 16;
    this.actionMenu.y = unit.y + 16;
    this.actionMenu.visible = true;
}

UIGroup.prototype.hideMenu = function() {
    this.actionMenu.visible = false;
}
