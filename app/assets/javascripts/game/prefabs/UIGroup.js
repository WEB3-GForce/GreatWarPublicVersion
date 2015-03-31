'use strict';

var UIGroup = function(game, parent) {
    Phaser.Group.call(this, game, parent);

    this.tileInfo = this.game.add.group();
    this.tileInfo.x = 8;
    this.tileInfo.y = 8;
    this.tileInfo.fixedToCamera = true;

    this.tileGraphics = this.game.add.graphics(0, 0, this.tileInfo);
    this.tileGraphics.beginFill(0x000000, 0.3);
    this.tileGraphics.drawRect(0, 0, 128, 48);

    this.currentTile = this.game.add.sprite(8, 8, 'terrain', 0, this.tileInfo);
    this.currentTile.alpha = 0.5;

    var font = { font: "18px Helvetica", fill: "#ffffff" };
    var smallerFont = { font: "14px Helvetica", fill: "#ffffff" };
    this.tileTitle = this.game.add.text(48, 24, "test",
					font,
					this.tileInfo);
    this.tileTitle.anchor.setTo(0, 0.5);

    this.unitInfo = this.game.add.group();
    this.unitInfo.y = 8;
    this.unitInfo.x = this.game.width - 128 - 8;
    this.unitInfo.fixedToCamera = true;

    this.unitGraphics = this.game.add.graphics(0, 0, this.unitInfo);
    this.unitGraphics.beginFill(0x000000, 0.3);
    this.unitGraphics.drawRect(0, 0, 128, 128);

    this.unitType = this.game.add.text(8, 8, "Infantry",
				       font,
				       this.unitInfo);
    this.unitHP = this.game.add.text(8, 40, "HP: 12/18",
				       smallerFont,
				       this.unitInfo);
    this.unitATK = this.game.add.text(8, 64, "ATK: 10",
				       smallerFont,
				       this.unitInfo);
    this.unitDEF = this.game.add.text(8, 88, "DEF: 20",
				       smallerFont,
				       this.unitInfo);
    this.unitInfo.alpha = 0;
};

UIGroup.prototype = Object.create(Phaser.Group.prototype);
UIGroup.prototype.constructor = UIGroup;

UIGroup.prototype.setTile = function(tile) {
    this.currentTile.frame = tile.index - 1;
    this.tileTitle.text = "tile #" + tile.index;
}

UIGroup.prototype.setUnit = function(unit) {
    if (unit) {
	this.unitHP.text = "HP: " + unit.stats.HP + "/" + unit.stats.MAX_HP;
	this.unitATK.text = "ATK: " + unit.stats.ATK;
	this.unitDEF.text = "DEF: " + unit.stats.DEF;
	this.unitInfo.alpha = 1;
    } else {
	this.unitInfo.alpha = 0;
    }
}
