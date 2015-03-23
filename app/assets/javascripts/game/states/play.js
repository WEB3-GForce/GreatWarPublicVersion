'use strict';

function Play() {
}

Play.prototype = {

    create: function() {
        game.world.setBounds(0, 0, width, height); // size of world, as opposed to window
        this.gameGroup = new GameGroup(this.game);

	this.game.input.onUp.add(function() {
	    var xDiff = Math.abs(this.game.input.mousePointer.positionDown.x -
		this.game.input.mousePointer.positionUp.x);
	    var yDiff = Math.abs(this.game.input.mousePointer.positionDown.y -
		this.game.input.mousePointer.positionUp.y);
	    if (xDiff <= 5 && yDiff <= 5) {
		console.log("clicked");
		// click stuff
		this.gameGroup.gameBoard.onClick();
	    }
	}, this);
    },

    update: function() {
        // Panning:
        this.moveCameraByPointer(this.game.input.mousePointer);

        // Updating the gameBoard
        this.gameGroup.gameBoard.update(); 
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
