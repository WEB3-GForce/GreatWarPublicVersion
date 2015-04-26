'use strict';

function Play() {
    this.sequences = [];
    this.currentSequence = null;
}

Play.prototype = {
    create: function() {
	// back-end to front-end
	this.game.channel.bind('rpc', (function(data) {
	    this.sequences.push(data.sequence);
    	}).bind(this));

	// front-end to back-end
    	this.game.dispatcher.rpc = function(action, args) {
    	    this.trigger("rpc", {action: action, arguments: args});
    	}

	this.game.dispatcher.rpc('init_game', {});

    	// size of world, as opposed to window
        this.game.world.setBounds(0, 0,
				  this.game.constants.WIDTH, this.game.constants.HEIGHT);

        this.game.animatingAction = false;

        this.gameGroup = new GameGroup(this.game);

        // deciding dragging vs. clicking:
    	this.game.input.onUp.add(function() {
    	    if (this.game.input.mousePointer.positionDown.x == this.game.input.mousePointer.position.x &&
                this.game.input.mousePointer.positionDown.y == this.game.input.mousePointer.position.y) {
    	           this.gameGroup.onClick(this.game.input.mousePointer.targetObject);
    	   }
    	}, this);

        this.backgroundSound = this.game.add.audio('ambience');
        this.backgroundSound.loop = true;
        this.backgroundSound.play();

        this.music = new Array(1);
        for (var i = 0; i < 1; i++) {
            this.music[i] = this.game.add.audio('music-'+i);
            this.music[i].volume = 0.5;
        }
        for (var i = 0; i < 1; i++) {
            this.music[i].onStop.add(function(next) {
                return function() {
                    this.music[next % 1].play();
                };
            }(i+1), this);
        }

        this.shakeTimerMax = 80;

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

        // shake the camera if there's an explosion:
        this.shakeCamera();
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

        if (this.currentAction && this.currentAction.arguments[3] == 'artillery') {
            this.cameraPos = {x: this.game.camera.x, y: this.game.camera.y};
            this.shakeTimer = this.shakeTimerMax;
        }

	    // for debugging
	    console.log(this.currentAction);

	    var action = this.gameGroup[this.currentAction.action].apply(
	        this.gameGroup,
	        this.currentAction.arguments
	    );
    	action.onComplete = (function() {
            this.game.animatingAction = false;
	        this.executeSequence();
	    }).bind(this);
        this.game.animatingAction = true;
	    action.start();
    },

    shakeCamera: function() {
        var delay = 30;

        if (this.shakeTimer > 0) {
            this.shakeTimer -= 1;
            if (this.shakeTimerMax - delay < this.shakeTimer) {
                return;
            }
            var shakeAmplitude = 10;
            var rand1 = this.game.rnd.integerInRange(-1 * shakeAmplitude, shakeAmplitude);
            var rand2 = this.game.rnd.integerInRange(-1 * shakeAmplitude, shakeAmplitude);
            // this.game.world.setBounds(rand1, rand2, this.game.width + rand1, this.game.height + rand2);
            this.game.camera.x = this.cameraPos.x + rand1;
            this.game.camera.y = this.cameraPos.y + rand2;
            if (this.shakeTimer == 0) {
                this.game.camera.x = this.cameraPos.x;
                this.game.camera.y = this.cameraPos.y;
            }
        }

    }
};
