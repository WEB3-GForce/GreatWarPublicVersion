'use strict';

var Infantry = function(game, x, y) {
    Phaser.Sprite.call(this, game, x, y, 'unit');
    this.animations.add('walk-left', [3, 4, 5, 4]);
    this.animations.add('walk-right', [6, 7, 8, 7]);
    this.animations.add('walk-down', [0, 1, 2, 1]);
    this.animations.add('walk-up', [9, 10, 11, 10]);


    this.animations.play('walk-down', 5, true);
};

Infantry.prototype = Object.create(Phaser.Sprite.prototype);
Infantry.prototype.constructor = Infantry;
