(function() {
  if (!window.Snake) {
    window.Snake = {};
  }


  var DIM_X = 40;
  var DIM_Y = 40;
  var DELTAS = {
    "N": [-1, 0],
    "S": [1, 0],
    "E": [0, -1],
    "W": [0, 1]
  };

  var Snake = window.Snake.Snake = function(board) {
    var startPos = [Math.floor(Math.random() * DIM_X), Math.floor(Math.random() * DIM_Y)];
    this.direction = "N";
    this.segments = []
    this.segments.push(startPos);
    this.board = board;
  };



  Snake.prototype.nextCoord = function () {
    var nextCoord = new Coord(this.segments[0])
    return nextCoord.plus(DELTAS[this.direction]);
  };

  Snake.prototype.move = function() {
    this.segments.unshift(this.nextCoord());
    this.segments.pop();
  };

  Snake.prototype.turn = function(dir) {
    this.direction = dir;
  };



  var Coord = window.Snake.coord = function (pos) {
    this.x = pos[0];
    this.y = pos[1];
  };

  Coord.prototype.plus = function (delta) {
    this.x += delta[0];
    this.y += delta[1];
    return [this.x, this.y]
  };

  Coord.prototype.pos = function() {
    return [this.x, this.y];
  }

  var Board = window.Snake.Board = function () {
    this.snake = new window.Snake.Snake();
    this.grid = this.newGrid();
    this.dimX = DIM_X;
    this.dimY = DIM_Y;

  };

  Board.prototype.newGrid = function() {
    var grid = [];
    for (var i = 0; i < DIM_X; i++) {
      var row = [];
      for (var j = 0; j < DIM_Y; j++) {
        row.push(".");
      }
      grid.push(row);
    }
    return grid;
  };


  Board.prototype.render = function() {
    this.grid = this.newGrid();
    for (var i = 0; i < this.snake.segments.length; i++) {
      var x = this.snake.segments[i][0];
      var y = this.snake.segments[i][1];
      this.grid[x][y] = "S";
    }
    return this.display();
  };

  Board.prototype.display = function() {
    // debugger
    var display = ""
    for (var j = 0; j < this.grid.length; j++) {
      for (var k = 0; k < this.grid[j].length; k++) {
        display += " " + this.grid[j][k];
      }
      display += "\n";
    }
    return display;
  }










})();

// (function() {
//   if (window.Coord == "undefined"){
//     window.Coord = {};
//   }
//
// })();
