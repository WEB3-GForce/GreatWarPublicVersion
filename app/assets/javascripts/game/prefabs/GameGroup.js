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

    this.turn = null;
    this.game.turnNumber = 0;

    this.players = null;
    this.game.constants.PLAYER_ID = "";
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
        console.log("trying to make the move unit rpc call");
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
    if (unit.isMine()) {
        this.selected = unit;
		this.ui.setUnit(this.selected);
		this.gameBoard.unhighlightAll();
		this.action = null;
		this.game.dispatcher.rpc("get_unit_actions", [this.selected.id]);
    }
}

GameGroup.prototype.buttonClicked = function(button) {
    this.action = button.key.replace('action-', '');
    this.ui.hideMenu();

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
    console.log("show Unit Actions");
    var action = {
    	gameGroup: this
    };
    action.start = function() {
		this.gameGroup.ui.showMenu(this.gameGroup.selected, unitActions);
    	this.onComplete();
    };
    return action;
}

GameGroup.prototype.highlightSquares = function(type, squares) {
    console.log("highlight Squares");
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

GameGroup.prototype.updateUnitsHealth = function(units) {
	var action = {
		unitGroup: this.unitGroup,
		ui: this.ui,
		data: units
	}
	action.units = units.map(function(unit) {
		return this.unitGroup.find(unit.id);
	}, this);
	action.tweens = units.map(function(unit, i) {
		return this.game.add.tween(action.units[i]).to({alpha: 0}, 500, null, false, 0, 5, true);
	}, this);
	action.start = function() {
		this.tweens[0].onComplete.add(function() {
	    		this.onComplete();
		}, this);
		this.tweens.map(function(tween, i) {
	    	tween.onComplete.add(function() {
				this.units[i].stats.HP = this.data[i].newHealth;
				this.units[i].alpha = 1;
	    	}, this);
		}, this);
		this.tweens.map(function(tween, i) {
	    	tween.start();
		}, this);
    }
    return action;
}

GameGroup.prototype.updateUnitEnergy = function(unitId, energyValue) {
	var action = {
		unit: this.unitGroup.find(unitId),
		ui: this.ui
	};
	action.start = function() {
		this.unit.stats.ENERGY = energyValue;
		this.ui.setUnit(this.unit);
		this.onComplete();
	};
	return action;
}

GameGroup.prototype.attack = function(unitId, square, type, unitType) {
    var unit = this.unitGroup.find(unitId);
    // check if need to add an animation to the receiving square
    return new AnimationAction(unit, type + "-attack");
}

GameGroup.prototype.moveUnit = function(unitId, square) {
    console.log("move Unit");
    console.log(unitId);
    console.log(square);

    var action = {};
    action.unit = this.unitGroup.find(unitId);
    action.start = function() {
    	// for (var i = 1, l = square.length; i < l; i++) {
    	// 	this.unit.moveTo(square[i].x, square[i].y);
    	// }
    	// this.onComplete();
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
