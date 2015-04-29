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
    this.turnCount = null;
    this.turnOver = false;

    this.players = null;
    this.game.constants.PLAYER_ID = null;
    // How are we going to do player names and stuff?

    this.ui = new UIGroup(this.game);
    this.ui.gameGroup = this;

    // check if end turn or end game
    this.game.input.keyboard.onDownCallback = (function(key) {
        var z = 90;
        var q = 81;

        if (key.keyCode === z) {
            if (this.myTurn()) {
	        this.game.dispatcher.rpc("end_turn", []); // backend will know whose turn to end
		this.turnOver = true;
		this.selected = null;
		this.action = null;
		this.gameBoard.unhighlightAll();
		this.ui.hideMenu().start();
            }
        } else if (key.keyCode === q) {
		this.game.dispatcher.rpc("leave_game", []);
        }
    }).bind(this);

    this.shakeAmplitude = 10;
    this.shakeTimerMax = 80;
};

GameGroup.prototype = Object.create(Phaser.Group.prototype);
GameGroup.prototype.constructor = GameGroup;

GameGroup.prototype.myTurn = function() {
    return this.turn === this.game.constants.PLAYER_ID && !this.turnOver;
}

GameGroup.prototype.update = function(mouse) {
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

    this.tile.name = this.gameBoard.getTerrainName(this.tile.index);
    this.tile.defense = this.gameBoard.getTerrainStats(this.tile.index).defense;
    this.tile.movementCost = this.gameBoard.getTerrainStats(this.tile.index).movementCost;

    if (this.selected) {
	this.ui.setSecondaryTile(this.tile);
	this.ui.setSecondaryUnit(this.unit);
    } else {
	this.ui.setSecondaryTile(null);
	this.ui.setSecondaryUnit(null);
	this.ui.setPrimaryTile(this.tile);
	this.ui.setPrimaryUnit(this.unit);
    }

    this.ui.checkPlayerInfoUIPosition({x: this.game.input.mousePointer.x,
				       y: this.game.input.mousePointer.y});

    if (this.shakeTimer >= 0) {
	this.shake();
	this.shakeTimer--;
    }
}

GameGroup.prototype.eliminatePlayer = function(playerId) {
    return {
	start: function() {
	    this.onComplete();
	}
    }
}

GameGroup.prototype.gameOver = function(playerId) {
    if (this.player == playerId) {
        this.game.endGameMessage = "You Win!"
    } else {
        this.game.endGameMessage = "You Lose!"
    }
    this.game.state.start('gameover');
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
            case 'trench':
		this.game.dispatcher.rpc("make_trench", [
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

GameGroup.prototype.makeTrench = function(unitId, square) {
    var action = {
	unit: this.unitGroup.find(unitId),
        gameBoard: this.gameBoard,
    };
    action.start = function() {
	this.unit.digTrench(function() {
            this.gameBoard.setTile(square.x, square.y, TRENCH_INDEX);
            this.onComplete();
	}, this);
    }
    return action;
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
    if (unit.isMine() && !this.game.animatingAction && !unit.disabled) {
        this.selected = unit;
	this.ui.setPrimaryUnit(this.selected);
	this.gameBoard.unhighlightAll();
	this.action = null;
	this.game.dispatcher.rpc("get_unit_actions", [this.selected.id]);
    }
}

GameGroup.prototype.buttonClicked = function(button) {
    if (button.key.substring(0, "ui-") === "ui-") {
	var action = button.key.replace('ui-', '');
	switch (action) {
	case 'expand':
	    this.ui.showPlayerMenu();
	    break;
	case 'contract':
	    break;
	}
    } else {
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
	case 'trench':
            this.game.dispatcher.rpc("get_unit_trench_locations", [this.selected.id]);
            break;
	}
    }
}

GameGroup.prototype.initGame = function(board, units, turn, players, me, effects) {
    var action = {
	gameGroup: this
    };

    action.start = function() {
	this.gameGroup.game.world.setBounds(0, 0, board.width * 32, board.height * 32);

	for (var i = 0; i < board.width; i++) {
	    for (var j = 0; j < board.height; j++) {
		this.gameGroup.gameBoard.setTile(i, j, board.squares[j*board.width+i].index);
		// if (board.squares[i*board.width+j].fow)
		// 	this.gameGroup.gameBoard.addFog(i, j);
	    }
	}

	this.gameGroup.gameBoard.effects = effects;
	this.gameGroup.gameBoard.handleEffects(effects);

	for (var i = 0; i < units.length; i++) {
	    this.gameGroup.unitGroup.addUnit(units[i].id,
					     units[i].type,
					     units[i].x,
					     units[i].y,
					     units[i].player,
					     units[i].stats,
					     players[units[i].player].faction);
	    this.gameGroup.game.dispatcher.rpc("check_unit_actions", [units[i].id]);
	}

	this.gameGroup.turn = turn.playerid;
	this.gameGroup.turnCount = turn.turnCount;
	this.gameGroup.players = players; // id corresponds to obj with name + type (red/blue)
	this.gameGroup.game.constants.PLAYER_ID = me;

	var playerIds = Object.keys(players);
	for (var i = 0; i < playerIds.length; i++) {
	    this.gameGroup.game.load.image(playerIds[i], players[playerIds[i]].gravatar);
	}

	this.gameGroup.game.load.onLoadComplete.add(function() {
	    this.gameGroup.ui.setPlayer(turn.playerid, this.gameGroup.players[turn.playerid], this.gameGroup.turnCount);
	    this.onComplete();
	}, this)
	this.gameGroup.game.load.start();
    }

    return action;
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

GameGroup.prototype.disableUnit = function(unitId) {
    var action = {
	unit: this.unitGroup.find(unitId)
    }
    action.start = function() {
	this.unit.disable();
	this.onComplete();
    }
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

GameGroup.prototype.resetUnits = function() {
    var units = this.unitGroup.all();
    for (var i = 0, unit; unit = units[i]; i++) {
        unit.stats.energy.current = unit.stats.energy.max;
        unit.enable();
    }
}

GameGroup.prototype.updateUnitHealth = function(unit, health) {
    var action = {
    	ui: this.ui,
    	unit: this.unitGroup.find(unit)
    }
    action.start = function() {
	this.tween = this.ui.updateHealth(action.unit, health, this.onComplete, this);
    	this.tween.start();
    }
    return action;
}

GameGroup.prototype.updateUnitEnergy = function(unitId, energyValue) {
    var action = {
	unit: this.unitGroup.find(unitId),
	ui: this.ui
    };

    action.start = function() {
	this.tween = this.ui.updateEnergy(action.unit, energyValue, this.onComplete, this);
    	this.tween.start();
    };
    return action;
}

GameGroup.prototype.attack = function(unitId, square, type, unitType) {
    // check if need to add an animation to the receiving square
    var action = {
    	unit: this.unitGroup.find(unitId),
	unitGroup: this.unitGroup,
	gameGroup: this
    };

    action.start = function() {
        action.unit.sound.play(type+"-start", function() {
            if (unitType === "artillery")
                this.gameGroup.startShake();
            this.tween = this.unit.attack(square, type);
            this.tween.onComplete.add(this.onComplete, this);
            this.tween.start();
            action.unit.sound.play(type+"-end");
        }, this);
    }
    return action;
}

GameGroup.prototype.moveUnit = function(unitId, squares) {
    var action = {};
    action.unit = this.unitGroup.find(unitId);
    action.move = function(squares) {
	if (squares.length === 1) {
	    this.unit.moveTo(squares[0].x, squares[0].y, true, this.onComplete, this);
	    return;
	}
	this.unit.moveTo(squares[0].x, squares[0].y, false, function() {
	    this.move(squares.slice(1))
	}, this);
    }
    action.start = function() {        
    action.unit.sound.play("move");
	this.move(squares);
    }
    return action;
}

GameGroup.prototype.revealUnit = function(unit) {
    var addedUnit = this.unitGroup.addUnit(unit.id,
					   unit.type,
					   unit.x,
					   unit.y,
					   unit.player,
					   unit.stats,
					   this.players[unit.player].faction);
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

GameGroup.prototype.setTurn = function(playerId, turnCount) {
    return {
	gameGroup: this,
	ui: this.ui,
	start: function() {
	    this.gameGroup.turn = playerId;
	    this.gameGroup.turnCount = turnCount;
	    this.gameGroup.turnOver = false;
	    this.ui.setPlayer(playerId, this.gameGroup.players[playerId], turnCount);
	    this.gameGroup.resetUnits();
	    var tween = this.ui.setTurnInfo(this.gameGroup.players[playerId]);
	    tween.onComplete.add(this.onComplete, this);
	    tween.start();
	}
    }
}

GameGroup.prototype.eliminatePlayer = function() {
    return {
	start: function() {
	    this.onComplete();
	}
    }
}

GameGroup.prototype.gameOver = function(id, forfeit) {
    return {
	gameGroup: this,
	start: function() {
	    var winner = this.gameGroup.players[id].name;
	    var loser;
	    var playerIds = Object.keys(this.gameGroup.players);
	    for (var i = 0; i < playerIds.length; i++) {
		if (playerIds[i] !== id)
		    loser = this.gameGroup.players[playerIds[i]].name;
	    }
	    var text;
	    if (id === this.gameGroup.game.constants.PLAYER_ID) {
		if (forfeit)
		    text = loser + " surrendered.\nYou won the battle!";
		else
		    text = "You won the battle against\n" + loser + "!";
	    } else {
		if (forfeit)
		    text = "You forfeited to\n" + winner + ".";
		else
		    text = "You lost the battle against\n" + winner + ".";
	    }

	    this.gameGroup.game.state.start('gameover', true, false, text);
	}
    };

}

GameGroup.prototype.startShake = function() {
    this.cameraPos = {x: this.game.camera.x, y: this.game.camera.y};
    this.shakeTimer = this.shakeTimerMax;
}

GameGroup.prototype.shake = function() {
    if (this.shakeTimer === 0) {
        this.game.world.setBounds(0, 0, this.game.width, this.game.height);
        //this.game.camera.x = this.cameraPos.x;
        //this.game.camera.y = this.cameraPos.y;
    } else {
	var rand1 = this.game.rnd.integerInRange(-1 * this.shakeAmplitude, this.shakeAmplitude);
	var rand2 = this.game.rnd.integerInRange(-1 * this.shakeAmplitude, this.shakeAmplitude);
	this.game.world.setBounds(rand1, rand2, this.game.width + rand1, this.game.height + rand2);
	//this.game.camera.x = this.cameraPos.x + rand1;
	//this.game.camera.y = this.cameraPos.y + rand2;
    }

}
