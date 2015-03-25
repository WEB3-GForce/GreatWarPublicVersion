'use strict';

function Play() {
}

Play.prototype = {
    create: function() {
        this.game.world.setBounds(0, 0, width, height); // size of world, as opposed to window

        this.game.gameGroup = new GameGroup(this.game);

    	this.game.receiver.bind('rpc', (function(data) {
    	    this.game.gameGroup.gameBoard[data.action].apply(this.game.gameGroup.gameBoard, data.arguments);
    	}).bind(this));

    	this.game.dispatcher.trigger("test");

        // deciding dragging vs. clicking: 
    	this.game.input.onUp.add(function() {
    	    if (this.game.input.mousePointer.positionDown.x == this.game.input.mousePointer.position.x && 
                this.game.input.mousePointer.positionDown.y == this.game.input.mousePointer.position.y) {
    	           this.game.gameGroup.onClick(this.game.input.mousePointer.targetObject);
    	   }
    	}, this);

        this.game.gameGroup.addUnit(2, 2);
    },

    update: function() {
        // Panning:
        this.moveCameraByPointer(this.game.input.mousePointer);

        // Updating the gameBoard
        this.game.gameGroup.gameBoard.update(); 
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
