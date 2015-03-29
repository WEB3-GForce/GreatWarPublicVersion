'use strict';

var UIGroup = function(game, parent) {
    Phaser.Group.call(this, game, parent);

    this.tileInfo = this.game.add.group();
    this.tileInfo.x = 8;
    this.tileInfo.y = 8;

    this.tileGraphics = this.game.add.graphics(0, 0, this.tileInfo);
    this.tileGraphics.beginFill(0x000000, 0.3);
    this.tileGraphics.drawRect(0, 0, 128, 48);

    this.currentTile = this.game.add.sprite(8, 8, 'terrain', 0, this.tileInfo);
    this.currentTile.alpha = 0.5;

    this.tileTitle = this.game.add.text(48, 24, "test",
					{ font: "18px Arial", fill: "#ffffff" },
				       this.tileInfo);
    this.tileTitle.anchor.setTo(0, 0.5);
};

UIGroup.prototype = Object.create(Phaser.Group.prototype);
UIGroup.prototype.constructor = UIGroup;

UIGroup.prototype.setTile = function(tile) {
    this.currentTile.frame = tile.index - 1;
    this.tileTitle.text = "tile #" + tile.index;
}
