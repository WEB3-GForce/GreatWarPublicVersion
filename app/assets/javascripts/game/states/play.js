'use strict';

/**
 * Play state. Initializes the game and handles sequence execution.
 * @constructor
 */
function Play() {
    this.sequences = [];
    this.currentSequence = null;
}

Play.prototype = {
    /**
     * Set up game related RPC bindings and sequence execution.
     */
    create: function() {
	// back-end to front-end
	this.game.channel.bind('rpc', (function(data) {
	    // add new sequence to queue
	    this.sequences.push(data.sequence);
    	}).bind(this));

	// front-end to back-end
    	this.game.dispatcher.rpc = function(action, args) {
    	    this.trigger("rpc", {action: action, arguments: args});
    	}

	// tell the back-end to start the game
	this.game.dispatcher.rpc('init_game', {});

    	// size of world, as opposed to window
        this.game.world.setBounds(0, 0,
				  this.game.constants.WIDTH, this.game.constants.HEIGHT);

        this.gameGroup = new GameGroup(this.game);

	// ensure that user cannot interact if an action is being played out
        this.gameGroup.animatingAction = false;

        // deciding dragging vs. clicking:
    	this.game.input.onUp.add(function() {
    	    if (this.game.input.mousePointer.positionDown.x == this.game.input.mousePointer.position.x &&
                this.game.input.mousePointer.positionDown.y == this.game.input.mousePointer.position.y) {
    	        this.gameGroup.onClick(this.game.input.mousePointer.targetObject);
    	    }
    	}, this);

	// music
        this.backgroundSound = this.game.add.audio('ambience');
        this.backgroundSound.loop = true;
        this.backgroundSound.volume = 0.5;
        this.backgroundSound.play();

        this.music = new Array(3);
        for (var i = 0; i < 3; i++) {
            this.music[i] = this.game.add.audio('music-'+i);
            this.music[i].volume = 0.6;
        }
        for (var i = 0; i < 3; i++) {
            this.music[i].onStop.add(function(next) {
                return function() {
                    this.music[next % 1].play();
                };
            }(i+1), this);
        }
        this.music[0].play();

	// camera shake time
        this.shakeTimerMax = 80;
    },

    /**
     * Execute sequences if there are any queued.
     */
    update: function() {
	// execute a sequence if one is available and no others are being executed
	if (this.currentSequence === null &&
	    this.sequences.length > 0) {
            this.currentSequence = this.sequences.shift();
	    this.executeSequence();
	}

        // Panning
        this.moveCameraByPointer(this.game.input.mousePointer);

        // Updating the gameBoard
        this.gameGroup.update();
    },

    /**
     * Handles panning if pointer is dragging
     */
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

    /**
     * Execute a sequence of actions in series via recursion.
     */
    executeSequence: function() {
	if (this.currentSequence.length === 0) {
	    this.currentSequence = null;
	    return;
	}
	this.currentAction = this.currentSequence.shift();

	// for debugging
	// console.log(this.currentAction);

	// use action prototype to allow for any type of action
	var action = this.gameGroup[this.currentAction.action].apply(
	    this.gameGroup,
	    this.currentAction.arguments
	);
    	action.onComplete = (function() {
            this.animatingAction = false;
	    this.executeSequence();
	}).bind(this);
        this.animatingAction = true;
	action.start();
    }
};
