'use strict';

var HIGHLIGHT_TYPES = {
    move: 1138,
    attack: 1139,
    trench: 1140
};

// none of these hashes should be accessed directly from outside of
// GameBoard. Use getTerrainName(index) and getTerrainStats(index) instead
var NAME_TO_INDEX = {};
var INDEX_TO_NAME = {};
var NAME_TO_FUNCTIONAL_TYPE = {
    Flatland: "flatland",
    Mountain: "mountain",
    Ocean: "mountain",
    Hill: "hill",
    Trench: "trench",
    River: "river",
    Waterfall: "mountain",
    Bridge: "flatland",
    Shore: "mountain",
    Forest: "hill",
    Ruins: "trenches",
    Road: "flatland"
};

var FUNCTIONAL_TYPE_TO_STATS = {
    flatland: {defense: 0, movementCost: 1},
    mountain: {defense: "N/A", movementCost: "N/A"},
    hill: {defense: 1, movementCost: 2},
    trench: {defense: 1, movementCost: 1},
    river: {defense: "N/A", movementCost: 1}
}

var GameBoard = function(game) {
    Phaser.Tilemap.call(this, game, 'tileset');

    this.addTilesetImage('fe', 'fe');
    this.addTilesetImage('fog', 'fog');
    this.addTilesetImage('highlight', 'highlight');

    var types = ['infantry', 'machinegun', 'artillery', 'command'];
    var colors = ['red', 'blue'];
    for (var i = 0; i < types.length; i++) {
	for (var j = 0; j < colors.length; j++) {
	    var str = types[i] + '-' + colors[j];
	    this.addTilesetImage(str, str);
	}
    }

    this.populateTerrainHash();

    this.terrainLayer = this.createLayer('terrainLayer'); // saved name of the layer
    this.fogLayer = this.createLayer('fogLayer');
    this.highlightLayer = this.createLayer('highlightLayer');

    this.drawGrid();
    this.unhighlightAll();
};

GameBoard.prototype = Object.create(Phaser.Tilemap.prototype);
GameBoard.prototype.constructor = GameBoard;

GameBoard.prototype.populateTerrainHash = function() {


    NAME_TO_INDEX["Flatland"] = [67, 68, 99];
    NAME_TO_INDEX["Mountain"]  =
		[567, 750, 751, 683, 546, 385, 353, 387, 619, 481, 583, 461, 578,
		 453, 385, 560, 491, 551, 618, 554, 681, 745, 712, 627, 680, 464, 588,
		 595, 782, 522, 427, 582, 614, 780, 747, 522, 427, 466, 433, 593,
         57, 25, 40, 509, 507, 508, 509];
    NAME_TO_INDEX["Hill"] = [653, 654, 655, 685, 686];
    NAME_TO_INDEX["Trench"] = [750];
    NAME_TO_INDEX["River"] = [631, 636, 632, 635, 603, 604, 599, 539, 629, 573, 597, 630,
        571, 600];
    NAME_TO_INDEX["Ocean"] = [213, 125]
    NAME_TO_INDEX["Waterfall"] = [567];
    NAME_TO_INDEX["Shore"] = [123, 91, 21, 25, 480, 380, 381, 382, 383, 507, 508, 509, 470,
        472, 474, 53, 55, 57, 221];
    NAME_TO_INDEX["Bridge"] = [35];
    NAME_TO_INDEX["Forest"] = [];
    NAME_TO_INDEX["Ruins"] = [];
    NAME_TO_INDEX["Road"] = [];

    for (var j = 0; j < Object.keys(NAME_TO_INDEX).length; j++) {
        for (var i = 1, index; index = NAME_TO_INDEX[Object.keys(NAME_TO_INDEX)[j]][i]; i++) {
            INDEX_TO_NAME[index] = Object.keys(NAME_TO_INDEX)[i];
        }
    }
}
GameBoard.prototype.getTerrainName = function(index) {
    return  INDEX_TO_NAME[index];
}
GameBoard.prototype.getTerrainStats = function(index) {
    // can avoid some errors this way:
    if (!FUNCTIONAL_TYPE_TO_STATS[NAME_TO_FUNCTIONAL_TYPE[INDEX_TO_NAME[index]]]) {
        return FUNCTIONAL_TYPE_TO_STATS["flatland"];
    }
    return FUNCTIONAL_TYPE_TO_STATS[NAME_TO_FUNCTIONAL_TYPE[INDEX_TO_NAME[index]]];
}


GameBoard.prototype.addFog = function(x, y) {
    var fogIndex = 50; // this is the index into the tilesheet and is a
    // terrible way to do this
    this.putTile(fogIndex, x, y, this.fogLayer);
}
GameBoard.prototype.revealFog = function(x, y) {
    this.removeTile(x, y, this.fogLayer);
}

GameBoard.prototype.isHighlighted = function(x, y) {
    return this.hasTile(x, y,
			this.highlightLayer);
}
GameBoard.prototype.highlight = function(x, y, type) {
    this.putTile(HIGHLIGHT_TYPES[type], x, y, this.highlightLayer);
}
GameBoard.prototype.unhighlight = function(x, y) {
    this.removeTile(x, y, this.highlightLayer);
}
GameBoard.prototype.unhighlightAll = function() {
    for (var i = 0; i < this.width; i++)
	for (var j = 0; j < this.height; j++)
	    this.unhighlight(i, j);
}
GameBoard.prototype.highlightRange = function(x, y, type, range) {
    if (range < 0 ||
	x < 0 || x >= this.width ||
	y < 0 || y >= this.height)
	return;
    this.highlight(x, y, type);
    this.highlightRange(x-1, y, type, range-1);
    this.highlightRange(x+1, y, type, range-1);
    this.highlightRange(x, y-1, type, range-1);
    this.highlightRange(x, y+1, type, range-1);
}

GameBoard.prototype.drawGrid = function() {
    this.grid = this.game.add.graphics();
    this.grid.lineStyle(1, 0x000000, 0.1);
    // draw vertical lines:
    for (var x = 0; x < this.width * this.game.constants.TILE_SIZE; x += this.game.constants.TILE_SIZE) {
    	this.grid.moveTo(x, 0);
    	this.grid.lineTo(x, this.height *  this.game.constants.TILE_SIZE)
    }
    // horizontal lines:
    for (var y = 0; y < this.height * this.game.constants.TILE_SIZE; y += this.game.constants.TILE_SIZE) {
    	this.grid.moveTo(0, y);
    	this.grid.lineTo(this.width * this.game.constants.TILE_SIZE, y);
    }
}

GameBoard.prototype.setTile = function(x, y, index) {
    this.putTile(index, x, y, this.terrainLayer);
}

GameBoard.prototype.terrainType = function(x, y) {
    this.getTile(x, y, this.terrainLayer);
}

GameBoard.prototype.terrainEffect = function(x, y) {
    return this.effects[this.terrainType(x, y)];
}
