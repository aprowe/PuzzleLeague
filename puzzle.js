(function() {
  var Base, Block, Board, ColorBlock, Game, Positional, Ticker, zz,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  zz = {};

  zz["class"] = {};

  Array.prototype.remove = function(item) {
    if (this.indexOf(item) > 0) {
      this.splice(this.indexOf(item), 1);
    }
    return item;
  };

  Array.prototype.fill = function(w, h) {
    var i, j, k, ref, ref1, results;
    for (i = j = 0, ref = w - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
      this[i] = [];
    }
    results = [];
    for (i = k = 0, ref1 = w - 1; 0 <= ref1 ? k <= ref1 : k >= ref1; i = 0 <= ref1 ? ++k : --k) {
      results.push(this[i][h] = void 0);
    }
    return results;
  };

  zz["class"].base = Base = (function() {
    function Base() {}

    Base.prototype._events = {};

    Base.prototype.on = function(event, fn) {
      if (this._events[event] == null) {
        this._events[event] = [];
      }
      return this._events[event].push(fn);
    };

    Base.prototype.unbind = function(event, fn) {
      if (fn == null) {
        return this._events[event] = [];
      }
    };

    Base.prototype.emit = function(event, args) {
      var fn, j, len, ref, results;
      if (this._events[event] == null) {
        return;
      }
      ref = this._events[event];
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        fn = ref[j];
        results.push(fn.apply(this, args));
      }
      return results;
    };

    return Base;

  })();

  zz["class"].positional = Positional = (function(superClass) {
    extend(Positional, superClass);

    function Positional() {
      return Positional.__super__.constructor.apply(this, arguments);
    }

    Positional.prototype.x = 0;

    Positional.prototype.y = 0;

    Positional.prototype.limit = function(bounds) {
      return this.on('check', (function(_this) {
        return function() {
          if (_this.x < bounds[0]) {
            _this.x = bounds[0];
          }
          if (_this.x > bounds[1]) {
            _this.x = bounds[1];
          }
          if (_this.y < bounds[2]) {
            _this.y = bounds[2];
          }
          if (_this.y > bounds[3]) {
            return _this.y = bounds[3];
          }
        };
      })(this));
    };

    Positional.prototype.move = function(x, y) {
      if (x.x != null) {
        y = x.y;
        x = x.x;
      }
      if (x.length != null) {
        x = x[0];
        y = x[1];
      }
      this.x += x;
      this.y += y;
      return this.check;
    };

    Positional.prototype.check = function() {
      return this.emit('check');
    };

    return Positional;

  })(Base);

  zz["class"].ticker = Ticker = (function(superClass) {
    extend(Ticker, superClass);

    function Ticker() {
      return Ticker.__super__.constructor.apply(this, arguments);
    }

    Ticker.prototype.framerate = 0;

    Ticker.prototype.running = false;

    Ticker.prototype.elapsed = 0;

    Ticker.prototype.start = function() {
      if (this.running) {
        return;
      }
      this.emit('start');
      this.running = true;
      return this.tick();
    };

    Ticker.prototype.stop = function() {
      if (!this.running) {
        return;
      }
      this.emit('stop');
      return this.running = false;
    };

    Ticker.prototype.tick = function() {
      this.emit('tick');
      if (this.running) {
        return setTimeout((function(_this) {
          return function() {
            _this.tick();
            return _this.elapsed++;
          };
        })(this), 1000 / this.framerate);
      }
    };

    return Ticker;

  })(Base);

  zz["class"].game = Game = (function(superClass) {
    extend(Game, superClass);

    Game.prototype.boards = [];

    Game.prototype.ticker = {};

    function Game() {
      this.ticker = new zz["class"].ticker;
      this.boards = [new Board, new Board];
    }

    Game.prototype.start = function() {
      return this.ticker.start();
    };

    return Game;

  })(Base);

  zz["class"].board = Board = (function(superClass) {
    extend(Board, superClass);

    Board.prototype.width = 8;

    Board.prototype.height = 10;

    Board.prototype.speed = 20;

    Board.prototype.counter = 0;

    Board.prototype.cursor = {};

    Board.prototype.renderer = null;

    function Board() {
      var c, i, j, k, ref, ref1, x, y;
      this.blocks = [];
      c = ['#', '@', '%', '*'];
      i = 0;
      for (y = j = 0, ref = this.height - 1; 0 <= ref ? j <= ref : j >= ref; y = 0 <= ref ? ++j : --j) {
        for (x = k = 0, ref1 = this.width - 1; 0 <= ref1 ? k <= ref1 : k >= ref1; x = 0 <= ref1 ? ++k : --k) {
          this.blocks.push(new ColorBlock(x, y, c[Math.round(Math.random() * 100) % 4]));
        }
      }
      this.cursor = new zz["class"].positional;
      this.cursor.limit([0, this.width - 1, 0, this.height]);
      Object.defineProperty(this, 'grid', {
        get: (function(_this) {
          return function() {
            return _this.blockArray();
          };
        })(this)
      });
    }

    Board.prototype.tick = function() {
      this.counter++;
      if (this.counter > this.speed) {
        return this.pushRow();
      }
    };

    Board.prototype.pushRow = function() {
      var b, j, len, ref, results;
      this.emit('pushRow');
      ref = this.blocks;
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        b = ref[j];
        results.push(b.y++);
      }
      return results;
    };

    Board.prototype.blockArray = function() {
      var b, j, len, ref;
      this._blockArray = [];
      this._blockArray.fill(this.width, this.height);
      ref = this.blocks;
      for (j = 0, len = ref.length; j < len; j++) {
        b = ref[j];
        this._blockArray[b.x][b.y] = b;
      }
      return this._blockArray;
    };

    Board.prototype.swap = function() {
      var b1, b2;
      b1 = this.grid[this.cursor.x][this.cursor.y];
      b2 = this.grid[this.cursor.x + 1][this.cursor.y];
      this.emit('swap', b1, b2);
      if (b1 != null) {
        b1.x = this.cursor.x + 1;
      }
      if (b2 != null) {
        return b2.x = this.cursor.x;
      }
    };

    Board.prototype.match = function(blocks) {
      this.emit('match', blocks);
      b.remove();
      return this.blocks.remove(b);
    };

    Board.prototype.getColumn = function(col) {
      if (col.x != null) {
        col = col.x;
      }
      return this.grid[col];
    };

    Board.prototype.getRow = function(row) {
      var i;
      if (row.y != null) {
        row = row.y;
      }
      return (function() {
        var j, ref, results;
        results = [];
        for (i = j = 0, ref = this.width - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
          results.push(this.grid[i][row]);
        }
        return results;
      }).call(this);
    };

    Board.prototype.getRows = function() {
      var i, j, ref, results;
      results = [];
      for (i = j = 0, ref = this.height - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
        results.push(this.getRow(i));
      }
      return results;
    };

    Board.prototype.getColumns = function() {
      return this.grid;
    };

    Board.prototype.getAdjacent = function(block) {
      var b, blocks;
      blocks = [];
      blocks.push(this.grid[block.x][block.y + 1]);
      blocks.push(this.grid[block.x][block.y - 1]);
      if (this.grid[block.x - 1] != null) {
        blocks.push(this.grid[block.x - 1][block.y]);
      }
      if (this.grid[block.x + 1] != null) {
        blocks.push(this.grid[block.x + 1][block.y]);
      }
      return (function() {
        var j, len, results;
        results = [];
        for (j = 0, len = blocks.length; j < len; j++) {
          b = blocks[j];
          if (b != null) {
            results.push(b);
          }
        }
        return results;
      })();
    };

    Board.prototype.checkRow = function(row) {
      var b, match, sets;
      sets = [];
      b = 0;
      while (b < row.length - 1) {
        match = [];
        while (true) {
          match.push(row[b]);
          if (!this.checkBlocks(row[b], row[++b])) {
            break;
          }
        }
        if (match.length >= 3) {
          sets.push(match);
        }
      }
      return sets;
    };

    Board.prototype.checkBlocks = function(b1, b2) {
      if (!((b1 != null) && (b2 != null))) {
        return false;
      }
      return b1.color === b2.color;
    };

    Board.prototype.getMatches = function() {
      var a, col, j, k, l, len, len1, len2, len3, matches, n, ref, ref1, ref2, ref3, row;
      matches = [];
      ref = this.getRows();
      for (j = 0, len = ref.length; j < len; j++) {
        row = ref[j];
        ref1 = this.checkRow(row);
        for (k = 0, len1 = ref1.length; k < len1; k++) {
          a = ref1[k];
          matches.push(a);
        }
      }
      ref2 = this.getColumns();
      for (l = 0, len2 = ref2.length; l < len2; l++) {
        col = ref2[l];
        ref3 = this.checkRow(col);
        for (n = 0, len3 = ref3.length; n < len3; n++) {
          a = ref3[n];
          matches.push(a);
        }
      }
      return matches;
    };

    Board.prototype.clearBlocks = function(blocks) {
      var b, j, len;
      for (j = 0, len = blocks.length; j < len; j++) {
        b = blocks[j];
        this.blocks.remove(b);
      }
      return this._blockArray = null;
    };

    Board.prototype.update = function() {
      var j, len, m, matches;
      this.cursor.emit('check');
      matches = this.getMatches();
      for (j = 0, len = matches.length; j < len; j++) {
        m = matches[j];
        this.clearBlocks(m);
      }
      return this.fallDown();
    };

    Board.prototype.fallDown = function() {
      var col, i, j, len, ref, results;
      ref = this.getColumns();
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        col = ref[j];
        col = col.sort(function(b1, b2) {
          var y1, y2;
          y1 = b1 != null ? b1.y : 1000;
          y2 = b2 != null ? b2.y : 1000;
          return y1 - y2;
        });
        results.push((function() {
          var k, ref1, results1;
          results1 = [];
          for (i = k = 0, ref1 = col.length - 1; 0 <= ref1 ? k <= ref1 : k >= ref1; i = 0 <= ref1 ? ++k : --k) {
            if (col[i] != null) {
              results1.push(col[i].y = i);
            } else {
              results1.push(void 0);
            }
          }
          return results1;
        })());
      }
      return results;
    };

    Board.prototype.render = function() {
      var col, j, k, ref, ref1, row, str;
      str = "";
      for (row = j = ref = this.height - 1; ref <= 0 ? j <= 0 : j >= 0; row = ref <= 0 ? ++j : --j) {
        str += "\n";
        for (col = k = 0, ref1 = this.width - 1; 0 <= ref1 ? k <= ref1 : k >= ref1; col = 0 <= ref1 ? ++k : --k) {
          if (row === this.cursor.y && col === this.cursor.x) {
            str += '[';
          } else {
            str += ' ';
          }
          if ((this.grid[col] != null) && (this.grid[col][row] != null)) {
            str += this.grid[col][row].color;
          } else {
            str += '-';
          }
          if (row === this.cursor.y && col === this.cursor.x + 1) {
            str += ']';
          } else {
            str += ' ';
          }
        }
      }
      return str;
    };

    return Board;

  })(Base);

  zz["class"].block = Block = (function(superClass) {
    extend(Block, superClass);

    function Block(x1, y3) {
      this.x = x1;
      this.y = y3;
    }

    return Block;

  })(Positional);

  zz["class"].block = ColorBlock = (function(superClass) {
    extend(ColorBlock, superClass);

    function ColorBlock(x1, y3, color) {
      this.x = x1;
      this.y = y3;
      this.color = color;
      ColorBlock.__super__.constructor.call(this, this.x, this.y);
    }

    return ColorBlock;

  })(Block);

  zz.game = new zz["class"].game;

  module.exports = zz;

}).call(this);
