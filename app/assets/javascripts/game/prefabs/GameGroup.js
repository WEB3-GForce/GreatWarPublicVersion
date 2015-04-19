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

    this.action = null;

    this.turn = "test";
    this.game.turnNumber = 0;

    this.players = null;
    this.game.constants.PLAYER_ID = "test";
    // How are we going to do player names and stuff?
    this.game.constants.PLAYER_NAME = "Pokemon General";

    this.ui = new UIGroup(this.game);
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

    if (this.game.input.mousePointer.targetObject &&
    	this.game.input.mousePointer.targetObject.sprite instanceof Unit) {
	this.unit = this.game.input.mousePointer.targetObject.sprite;
    } else {
	this.unit = null;
    }

    if (this.selected) {
	this.ui.setSecondaryTile(this.tile);
	this.ui.setSecondaryUnit(this.unit);
    } else {
	this.ui.setSecondaryTile(null);
	this.ui.setSecondaryUnit(null);
	this.ui.setPrimaryTile(this.tile);
	this.ui.setPrimaryUnit(this.unit);
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
		this.game.dispatcher.rpc("move_unit", [
		    this.selected.id,
		    {
			x: this.tile.x,
			y: this.tile.y
		    }
		]);
		break;
	    case 'ranged':
		break;
	    case 'melee':
		break;
	    }
	}
	this.selected = null;
	this.action = null;
	this.gameBoard.unhighlightAll();
	this.ui.hideMenu().start();
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
			this.game.dispatcher.rpc("attack", [
			    this.selected.id,
			    {x: this.tile.x, y: this.tile.y},
			    this.action
			]);
			this.selected = null;
		    }
		}
		this.gameBoard.unhighlightAll();
		this.action = null;
    }
}

GameGroup.prototype.select = function(unit) {
    if (unit.isMine() && !this.game.animatingAction) {
        this.selected = unit;
	this.ui.setPrimaryUnit(this.selected);
	this.gameBoard.unhighlightAll();
	this.action = null;
	this.game.dispatcher.rpc("get_unit_actions", [this.selected.id]);
    }
}

GameGroup.prototype.buttonClicked = function(button) {
    this.action = button.key.replace('action-', '');
    this.ui.hideMenu().start();

    switch (this.action) {
    case 'move':
	this.game.dispatcher.rpc("get_unit_moves", [this.selected.id]);
	break;
    case 'ranged':
	this.game.dispatcher.rpc("get_unit_ranged_attacks", [this.selected.id]);
	break;
    case 'melee':
	this.game.dispatcher.rpc("get_unit_melee_attacks", [this.selected.id]);
	break;
    case 'endTurn':
    // this.game.dispatcher.rpc("end_turn", [this.turn]);
    this.resetEnergy(this.turn);
    this.turnNumber += 1;
    break;
    }
}

GameGroup.prototype.initGame = function(board, units, turn, players) {
    for (var i = 0; i < board.width; i++) {
	    for (var j = 0; j < board.height; j++) {
	        this.gameBoard.setTile(i, j, board.squares[i*board.width+j].terrain);
	        if (board.squares[i*board.width+j].fow)
		        this.gameBoard.addFog(i, j);
	    }
    }

    // effects is not passed right now
    // this.gameBoard.effects = effects;

    for (var i = 0; i < units.length; i++) {
	    this.unitGroup.addUnit(units[i].id,
			       units[i].type,
			       units[i].x,
			       units[i].y,
			       units[i].player,
			       units[i].stats);
    }

    this.turn = turn.playerid;
    this.players = players;
    // There should be a better/different way to do this
    this.game.constants.PLAYER_ID = this.turn;

    return { start: function() { this.onComplete(); } }
}

GameGroup.prototype.showUnitActions = function(unitActions) {
    var action = {
    	gameGroup: this
    };
    action.start = function() {
	if (this.gameGroup.ui.menuVisible()) {
	    var hideTween = this.gameGroup.ui.hideMenu();
	    hideTween.onComplete.add(function() {
		var showTween = this.gameGroup.ui.showMenu(this.gameGroup.selected, unitActions);
		showTween.onComplete.add(this.onComplete, this);
		showTween.start();
	    }, this);
	    hideTween.start();
	} else {
	    var showTween = this.gameGroup.ui.showMenu(this.gameGroup.selected, unitActions);
	    showTween.onComplete.add(this.onComplete, this);
	    showTween.start();
	}
    };
    return action;
}

GameGroup.prototype.highlightSquares = function(type, squares) {
    var action = {
		squares: squares,
		gameBoard: this.gameBoard,
		type: type
	};
	action.start = function() {
		for (var i = 0, square; square = this.squares[i]; i++) {
			var tile = this.gameBoard.getTile(square.x, square.y, this.gameBoard.terrainLayer);
			this.gameBoard.highlight(tile.x, tile.y, type);
		}
		this.onComplete();
	};
	return action;
}

GameGroup.prototype.revealFog = function(squares) {
	var action = {
		squares: squares,
		gameBoard: this.gameBoard
	};
	action.start = function() {
		for (var i = 0, square; square = this.squares[i]; i++) {
			var tile = this.gameBoard.getTile(square.x, square.y, this.gameBoard.terrainLayer);
			this.gameBoard.revealFog(tile.x, tile.y);
		}
		this.onComplete();
	};
	return action;
}

GameGroup.prototype.resetEnergy = function(playerId) {
    var units = this.unitGroup.getAllByPlayer(playerId);
    for (var i = 0, unit; unit = units[i]; i++) {
        unit.stats.ENERGY = unit.stats.MAX_ENERGY;
    }
}

GameGroup.prototype.updateUnitHealth = function(unit, health) {
    var action = {
    	ui: this.ui,
    	unit: this.unitGroup.find(unit)
    }
    action.tween = this.ui.updateHealth(action.unit, health);
    action.start = function() {
    	this.tween.onComplete.add(function() {
    	    this.onComplete();
    	}, this);
    	this.tween.start();
    }
    return action;
}

GameGroup.prototype.updateUnitEnergy = function(unitId, energyValue) {
    var action = {
	unit: this.unitGroup.find(unitId),
	ui: this.ui
    };
    action.tween = this.ui.updateEnergy(action.unit, energyValue);

    action.start = function() {
    	this.tween.onComplete.add(function() {
    	    this.onComplete();
    	}, this);
    	this.tween.start();
    };
    return action;
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

GameGroup.prototype.killUnits = function(unitIds) {
    var action = {};
    action.unitGroup = this.unitGroup;
    action.units = unitIds.map(function(unitId) {
	return this.unitGroup.find(unitId);
    }, this);
    action.tweens = unitIds.map(function(unitId, i) {
	return this.game.add.tween(action.units[i]).to({alpha: 0}, 300);
    }, this);
    action.start = function() {
	this.tweens[0].onComplete.add(function() {
	    this.onComplete();
	}, this);
	this.tweens.map(function(tween, i) {
	    tween.onComplete.add(function() {
		this.unitGroup.removeUnit(this.units[i].id);
	    }, this);
	}, this);
	this.tweens.map(function(tween, i) {
	    tween.start();
	}, this);
    }
    return action;
}

GameGroup.prototype.setTurn = function(playerId) {
    this.gameGroup = this;
    return {
	start: function() {
	    this.gameGroup.turn = playerId;
	    this.onComplete();
	}
    };
}
