'use strict';

var GameGroup = function(game, parent) {
    Phaser.Group.call(this, game, parent);

    this.gameBoard = new GameBoard(this.game);
    this.selected = null;
    this.unitGroup = new UnitGroup(this.game);

    this.marker = this.game.add.graphics();
    this.marker.lineStyle(2, 0x000000, 1);
    this.marker.drawRect(0, 0, this.game.constants.TILE_SIZE, this.game.constants.TILE_SIZE);
    this.tile = null;

    this.ui = new UIGroup(this.game);

    this.action = null;

    this.turn = null;
    this.players = null;
    this.game.constants.PLAYER_ID = "test"
};

GameGroup.prototype = Object.create(Phaser.Group.prototype);
GameGroup.prototype.constructor = GameGroup;

GameGroup.prototype.myTurn = function() {
    return this.turn === this.game.constants.PLAYER_ID;
}

GameGroup.prototype.update = function() {
    // moving the marker
    this.marker.x = this.gameBoard.highlightLayer.getTileX(this.game.input.activePointer.worldX) * this.game.constants.TILE_SIZE;
    this.marker.y = this.gameBoard.highlightLayer.getTileY(this.game.input.activePointer.worldY) * this.game.constants.TILE_SIZE;

    this.tile = this.gameBoard.getTile(this.marker.x/this.game.constants.TILE_SIZE,
				       this.marker.y/this.game.constants.TILE_SIZE,
				       this.gameBoard.terrainLayer);

    this.ui.setTile(this.tile);

    if (this.game.input.mousePointer.targetObject && 
    	this.game.input.mousePointer.targetObject.sprite instanceof Unit && 
    	!this.selected) {
		this.ui.setUnit(this.game.input.mousePointer.targetObject.sprite);
    } else if (!this.selected) {
 		this.ui.setUnit(null);
 	}
}

GameGroup.prototype.onClick = function(targetObject) {
    if (targetObject === null) {
		this.tileClicked();
    } else if (targetObject.sprite instanceof Unit) {
		this.unitClicked(targetObject.sprite);
    } else if (targetObject.sprite instanceof Phaser.Button) {
		this.buttonClicked(targetObject.sprite);
    }
}

GameGroup.prototype.tileClicked = function() {
    if (!this.myTurn())
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
    if (!this.myTurn())
	return;

    if (this.action) {
		this.interact(unit);
    } else {
		this.select(unit);
    }
}

GameGroup.prototype.interact = function(unit) {
    if (this.gameBoard.isHighlighted(this.tile.x, this.tile.y)) {
		if (unit.isMine()) {
		    // maybe later we have within-team interaction
		    this.select(unit); // just select the clicked unit for now though
		} else {
		    // clicked enemy unit
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
    if (unit.isMine()) {
		this.selected = unit;
		this.ui.setUnit(this.selected);
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
    this.gameBoard.highlightRange(this.selected.x/this.game.constants.TILE_SIZE,
				  this.selected.y/this.game.constants.TILE_SIZE,
				  highlightType, range);
}

GameGroup.prototype.initGame = function(board, effects, units, turn, players) {
    for (var i = 0; i < board.width; i++) {
	for (var j = 0; j < board.height; j++) {
	    this.gameBoard.setTile(i, j, board.squares[i*board.width+j].terrain);
	    if (board.squares[i*board.width+j].fow)
		this.gameBoard.addFog(i, j);
	}
    }

    this.gameBoard.effects = effects;

    for (var i = 0; i < units.length; i++) {
	this.unitGroup.addUnit(units[i].id,
			       units[i].type,
			       units[i].x,
			       units[i].y,
			       units[i].player,
			       units[i].stats);
    }

    this.turn = turn;
    this.players = players;
    return { start: function() { this.onComplete(); } }
}

GameGroup.prototype.attack = function(unitId, square, type, unitType) {
    var unit = this.unitGroup.find(unitId);
    // check if need to add an animation to the receiving square
    return new AnimationAction(unit, type + "-attack");
}

GameGroup.prototype.moveUnit = function(unitId, square) {
    var action = {};
    action.unit = this.unitGroup.find(unitId);
    action.start = function() {
	this.unit.moveTo(square.x, square.y, this.onComplete, this);
    }
    return action;
}

GameGroup.prototype.revealUnit = function(unit) {
    var addedUnit = this.unitGroup.addUnit(unit.id,
					   unit.type,
					   unit.x,
					   unit.y,
					   unit.player,
					   unit.stats);
    addedUnit.alpha = 0;
    return new TweenAction(this.game.add.tween(addedUnit).to({alpha: 1}, 300));
}

GameGroup.prototype.killUnit = function(unitId) {
    var action = {};
    action.unit = this.unitGroup.find(unitId);
    delete this.unitGroup.idLookup[unitId];
    action.tween = this.game.add.tween(action.unit).to({alpha: 0}, 300);
    action.start = function() {
	this.tween.onComplete.add(function() {
	    this.unit.destroy();
	    this.onComplete();
	}, this);
	this.tween.start();
    }
    return action;
}
