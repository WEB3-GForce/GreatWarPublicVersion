'use strict';

var Infantry = function(game, x, y, key, frame) {
    Phaser.Sprite.call(this, game, x, y, key, frame);
    console.log("hi i'm infantry");
};

Infantry.prototype = Object.create(Phaser.Sprite.prototype);
Infantry.prototype.constructor = Infantry;
