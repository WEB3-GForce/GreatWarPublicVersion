'use strict';

function Play() {
    this.sequences = [];
    this.currentSequence = null;
}

Play.prototype = {
    create: function() {
	// size of world, as opposed to window
        this.game.world.setBounds(0, 0,
				  this.game.constants.WIDTH, this.game.constants.HEIGHT);

        this.gameGroup = new GameGroup(this.game);

    	this.game.dispatcher.bind('rpc', (function(data) {
	    this.sequences.push(data.sequence);
    	}).bind(this));

	this.game.dispatcher.rpc = function(action, args) {
	    this.trigger("rpc", {action: action, arguments: args});
	}
    	this.game.dispatcher.rpc("init_game", []);

        // deciding dragging vs. clicking: 
    	this.game.input.onUp.add(function() {
    	    if (this.game.input.mousePointer.positionDown.x == this.game.input.mousePointer.position.x && 
                this.game.input.mousePointer.positionDown.y == this.game.input.mousePointer.position.y) {
    	           this.gameGroup.onClick(this.game.input.mousePointer.targetObject);
    	   }
    	}, this);
    },

    update: function() {
	// executing actions
	if (this.currentSequence === null &&
	    this.sequences.length > 0) {
	    this.currentSequence = this.sequences.shift();
	    this.executeSequence();
	}

        // Panning:
        this.moveCameraByPointer(this.game.input.mousePointer);

        // Updating the gameBoard
        this.gameGroup.update(); 
    },

    moveCameraByPointer: function(pointer) {
        if (!pointer.timeDown) { return; }
        if (pointer.isDown && !pointer.targetObject) {
            if (this.playCamera) {
                this.game.camera.x += this.playCamera.x - pointer.position.x;
                this.game.camera.y += this.playCamera.y - pointer.position.y;
            }
            this.playCamera = pointer.position.clone();
        }
        if (pointer.isUp) { this.playCamera = null; }
    },

    executeSequence: function() {
	if (this.currentSequence.length == 0) {
	    this.currentSequence = null;
	    return;
	}
	this.currentAction = this.currentSequence.shift();
	var action = this.gameGroup[this.currentAction.action].apply(
	    this.gameGroup,
	    this.currentAction.arguments
	);
	action.onComplete = (function() {
	    this.executeSequence();
	}).bind(this);
	action.start();
    }
};
