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

UnitGroup.prototype.addUnit = function(id, type, x, y, player, stats, faction) {
    this.idLookup[id] = new Unit(this.game, id, type, x, y, player, stats, faction)
    this.add(this.idLookup[id]);
    return this.idLookup[id];
}

UnitGroup.prototype.removeUnit = function(id) {
    var unit = this.idLookup[id];
    unit.sound.play("die");
    delete this.idLookup[id];
    this.remove(unit, true);
}

UnitGroup.prototype.all = function() {
    var units = [];
    var keys = Object.keys(this.idLookup);
    for (var i = 0; i < keys.length; i++) {
	units.push(this.idLookup[keys[i]]);
    }
    return units;
}
