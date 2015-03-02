'use strict';

function Play() {
}

Play.prototype = {

    create: function() {

        game.world.setBounds(0, 0, width, height); // size of world, as opposed to window

        game_group = game.add.group();
        UI_group = game.add.group();
        UI_group.fixedToCamera = true;

        var board = game.add.tilemap('tileset');
        board.addTilesetImage('tmw_desert_spacing', // tileset name, findable in the json 
            'tiles'
        );

        var backgroundLayer = board.createLayer('boardLayer'); // saved name of the layer
        game_group.add(backgroundLayer);

        // Adding units
        var unit1 = game_group.create(tile_size * trench_x, tile_size * trench_y, 'infantry_right');
    },

    update: function() {
        // Panning:
        this.moveCameraByPointer(game.input.mousePointer);
        this.moveCameraByPointer(game.input.pointer1);
    },

    clickListener: function() {
	   
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
