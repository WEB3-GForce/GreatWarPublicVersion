'use strict';

function Play() {
}

Play.prototype = {
    create: function() {
        this.game.world.setBounds(0, 0, width, height); // size of world, as opposed to window

        this.gameGroup = new GameGroup(this.game);

    	this.game.dispatcher.bind('rpc', (function(data) {
	    console.log(data);
    	    this.gameGroup[data.action].apply(this.gameGroup, data.arguments);
    	}).bind(this));

    	this.game.dispatcher.trigger("init_game");

        // deciding dragging vs. clicking: 
    	this.game.input.onUp.add(function() {
    	    if (this.game.input.mousePointer.positionDown.x == this.game.input.mousePointer.position.x && 
                this.game.input.mousePointer.positionDown.y == this.game.input.mousePointer.position.y) {
    	           this.gameGroup.onClick(this.game.input.mousePointer.targetObject);
    	   }
    	}, this);

	this.gameGroup.addUnit(2, 2, true);
	this.gameGroup.addUnit(2, 3, true);
	this.gameGroup.addUnit(2, 4, true);
	this.gameGroup.addUnit(4, 2, false);
	this.gameGroup.addUnit(4, 3, false);
	this.gameGroup.addUnit(4, 4, false);
	// for (var i = 0; i < 10; i++)
        //     this.gameGroup.addUnit(Math.floor(Math.random() * 30),
	// 			   Math.floor(Math.random() * 30),
	// 			   Math.random() > 0.5 ? true : false);
    },

    update: function() {
        // Panning:
        this.moveCameraByPointer(this.game.input.mousePointer);

        // Updating the gameBoard
        this.gameGroup.update(); 
    },

    moveCameraByPointer: function(pointer) {
        if (!pointer.timeDown) { return; }
        if (pointer.isDown && !pointer.targetObject) {
            if (play_camera) {
                game.camera.x += play_camera.x - pointer.position.x;
                game.camera.y += play_camera.y - pointer.position.y;
            }
            play_camera = pointer.position.clone();
        }
        if (pointer.isUp) { play_camera = null; }
    }
};
