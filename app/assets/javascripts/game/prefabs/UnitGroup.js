'use strict';

var UnitGroup = function(game, parent) {
    Phaser.Group.call(this, game, parent);
    
    this.idLookup = {};
};

UnitGroup.prototype = Object.create(Phaser.Group.prototype);
UnitGroup.prototype.constructor = UnitGroup;

UnitGroup.prototype.find = function(id) {
    return this.idLookup[id];
}

UnitGroup.prototype.addUnit = function(id, type, x, y, player, stats) {
    this.idLookup[id] = new Unit(this.game, id, type, x, y, player, stats)
    this.add(this.idLookup[id]);
    return this.idLookup[id];
}

