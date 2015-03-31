'use strict';

var GameGroup = function(game, parent) {
    Phaser.Group.call(this, game, parent);

    this.gameBoard = new GameBoard(this.game);
    this.selected = null;
    this.unitGroup = this.game.add.group();

    this.marker = this.game.add.graphics();
    this.marker.lineStyle(2, 0x000000, 1);
    this.marker.drawRect(0, 0, 32, 32); // THIS IS HARDCODE
    this.tile = null;

    this.ui = new UIGroup(this.game);

    this.action = null;

    this.myTurn = true;
};

GameGroup.prototype = Object.create(Phaser.Group.prototype);
GameGroup.prototype.constructor = GameGroup;

GameGroup.prototype.update = function() {
    // moving the marker
    this.marker.x = this.gameBoard.highlightLayer.getTileX(this.game.input.activePointer.worldX) * 32;
    this.marker.y = this.gameBoard.highlightLayer.getTileY(this.game.input.activePointer.worldY) * 32;

    this.tile = this.gameBoard.getTile(this.marker.x/32,
				       this.marker.y/32,
				       this.gameBoard.terrainLayer);

    this.ui.setTile(this.tile);

    if (this.game.input.mousePointer.targetObject && 
    	this.game.input.mousePointer.targetObject.sprite instanceof Infantry && 
    	!this.selected) {
		this.ui.setUnit(this.game.input.mousePointer.targetObject.sprite);
    } else if (!this.selected) {
 		this.ui.setUnit(null);
 	}
}

GameGroup.prototype.onClick = function(targetObject) {
    if (targetObject === null) {
	this.tileClicked();
    } else if (targetObject.sprite instanceof Infantry) {
	this.unitClicked(targetObject.sprite);
    } else if (targetObject.sprite instanceof Phaser.Button) {
	this.buttonClicked(targetObject.sprite);
    }
}

GameGroup.prototype.addUnit = function(x, y, mine) {
    this.unitGroup.add(new Infantry(this.game, x, y, mine));
}

GameGroup.prototype.tileClicked = function() {
    if (!this.myTurn)
	return;
    // tile
    if (this.selected) {
	if (this.gameBoard.isHighlighted(this.tile.x, this.tile.y)) {
	    switch (this.action) {
	    case 'move':
		this.selected.moveTo(this.tile.x, this.tile.y);
		break;
	    case 'ranged':
		break;
	    case 'melee':
		break;
	    }
	}
	this.ui.hideMenu();
	this.selected = null;
	this.action = null;
	this.gameBoard.unhighlightAll();
    }
}


GameGroup.prototype.unitClicked = function(unit) {
    if (!this.myTurn)
	return;

    if (this.action) {
	this.interact(unit);
    } else {
	this.select(unit);
    }
}

GameGroup.prototype.interact = function(unit) {
    if (this.gameBoard.isHighlighted(this.tile.x, this.tile.y)) {
	if (unit.mine) {
	    // maybe later we have within team interaction
	    this.select(unit);
	} else {
	    // selected enemy unit
	    if ((this.action === 'ranged' || this.action === 'melee')) {
		this.selected.attack(unit, this.action);
		this.selected = null;
	    }
	}
	this.gameBoard.unhighlightAll();
	this.action = null;
    }
}

GameGroup.prototype.select = function(unit) {
    if (unit.mine) {
	this.selected = unit;
	this.ui.showMenu(this.selected);
	this.gameBoard.unhighlightAll();
	this.action = null;
    }
}

GameGroup.prototype.buttonClicked = function(button) {
    this.action = button.key.replace('action-', '');
    this.ui.hideMenu();

    var highlightType, range;
    switch (this.action) {
    case 'move':
	highlightType = 'blue';
	range = this.selected.stats.MOV;
	break;
    case 'ranged':
	highlightType = 'red';
	range = this.selected.stats.RNG;
	break;
    case 'melee':
	highlightType = 'red';
	range = this.selected.stats.MEL;
	break;
    }
    this.gameBoard.highlightRange(this.selected.x/32, this.selected.y/32,
				  highlightType, range);
}
