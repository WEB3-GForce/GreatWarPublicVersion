'use strict';

function Play() {
}

Play.prototype = {

    create: function() {

        game.world.setBounds(0, 0, width, height); // size of world, as opposed to window

        this.gameGroup = new GameGroup(this.game);
    },

    update: function() {
        // Panning:
        this.moveCameraByPointer(game.input.mousePointer);
        this.moveCameraByPointer(game.input.pointer1);
    },

    moveCameraByPointer: function (pointer) {
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
