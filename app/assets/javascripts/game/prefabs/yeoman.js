'use strict';

var Yeoman = function(game, x, y, frame) {
    Phaser.Sprite.call(this, game, x, y, 'yeoman', frame);
    
    this.inputEnabled = true;

    this.game.physics.arcade.enable(this);
    this.body.collideWorldBounds = true;
    this.body.bounce.setTo(1,1);
    this.body.velocity.x = this.game.rnd.integerInRange(-500,500);
    this.body.velocity.y = this.game.rnd.integerInRange(-500,500);
};

Yeoman.prototype = Object.create(Phaser.Sprite.prototype);
Yeoman.prototype.constructor = Yeoman;
