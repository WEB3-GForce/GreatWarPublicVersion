'use strict';

/**
 * Handles finding, adding, and removing units.
 * @constructor
 * @augments Phaser.Group
 * @param {Phaser.Game} game - Game object
 * @param {Phaser.Group} parent - the group to which UnitGroup should belong
 */
var UnitGroup = function(game, parent) {
    Phaser.Group.call(this, game, parent);

    this.idLookup = {};
};

UnitGroup.prototype = Object.create(Phaser.Group.prototype);
UnitGroup.prototype.constructor = UnitGroup;

/**
 * Finds the unit with that entity id.
 * @param {string} id - entity id
 */
UnitGroup.prototype.find = function(id) {
    return this.idLookup[id];
}

/**
 * Create a new unit and add it to the group.
 * @param {string} id - entity id
 * @param {type} string - unit type
 * @param {integer} x - x-coordinate (tile)
 * @param {integer} y - y-coordinate (tile)
 * @param {string} player - entity id of the unit's owner
 * @param {object} stats - the unit's stats
 * @param {string} faction - the player's faction (red vs. blue)
 */
UnitGroup.prototype.addUnit = function(id, type, x, y, player, stats, faction) {
    this.idLookup[id] = new Unit(this.game, id, type, x, y, player, stats, faction)
    this.add(this.idLookup[id]);
    return this.idLookup[id];
}

/**
 * Removes the unit from the group
 * @param {string} id - entity id
 */
UnitGroup.prototype.removeUnit = function(id) {
    var unit = this.idLookup[id];
    delete this.idLookup[id];
    this.remove(unit, true);
}

/**
 * Gets all unit objects as an array
 */
UnitGroup.prototype.all = function() {
    var units = [];
    var keys = Object.keys(this.idLookup);
    for (var i = 0; i < keys.length; i++) {
	units.push(this.idLookup[keys[i]]);
    }
    return units;
}
