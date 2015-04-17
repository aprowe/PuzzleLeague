(function() {
  var root,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  root = typeof window !== "undefined" && window !== null ? window : this;

  (function(factory) {
    if (typeof exports === 'object') {
      return module.exports = factory.call(root);
    } else if (typeof define === 'function' && define.amd) {
      return define(function() {
        return factory.call(root);
      });
    } else {
      return root.zz = factory.call(root);
    }
  })(function() {
    var Base, Block, Board, BoardRenderer, CanvasBoardRenderer, CanvasRenderer, ColorBlock, Controller, EventController, Game, Positional, Renderer, Ticker, bigBlock, forall, zz;
    zz = {};
    zz["class"] = {};
    Array.prototype.remove = function(item) {
      if (this.indexOf(item) > 0) {
        this.splice(this.indexOf(item), 1);
      }
      return item;
    };
    Array.prototype.fill = function(w, h) {
      var i, k, l, ref, ref1, results;
      for (i = k = 0, ref = w - 1; 0 <= ref ? k <= ref : k >= ref; i = 0 <= ref ? ++k : --k) {
        this[i] = [];
      }
      results = [];
      for (i = l = 0, ref1 = w - 1; 0 <= ref1 ? l <= ref1 : l >= ref1; i = 0 <= ref1 ? ++l : --l) {
        results.push(this[i][h] = void 0);
      }
      return results;
    };
    forall = function(w, h, fn) {
      var arr, i, j, k, l, ref, ref1;
      arr = [];
      for (i = k = 0, ref = w - 1; 0 <= ref ? k <= ref : k >= ref; i = 0 <= ref ? ++k : --k) {
        for (j = l = 0, ref1 = h - 1; 0 <= ref1 ? l <= ref1 : l >= ref1; j = 0 <= ref1 ? ++l : --l) {
          arr.push(fn(i, j));
        }
      }
      return arr;
    };
    zz["class"].base = Base = (function() {
      Base.prototype.defaults = {};

      function Base(_events) {
        var key, ref, value;
        this._events = _events != null ? _events : {};
        this._events = {};
        this._queue = {};
        ref = this.defaults;
        for (key in ref) {
          value = ref[key];
          this[key] = value;
        }
      }

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
        var fn, k, len, ref, results;
        if (this['on' + event] != null) {
          this['on' + event].call(this, args);
        }
        if (this._events[event] == null) {
          return;
        }
        ref = this._events[event];
        results = [];
        for (k = 0, len = ref.length; k < len; k++) {
          fn = ref[k];
          results.push(fn.call(this, args));
        }
        return results;
      };

      Base.prototype.done = function(event) {
        if (this._queue[event] == null) {
          return;
        }
        this._queue[event][0].call(this, this._queue[event][1]);
        return delete this._queue[event];
      };

      Base.prototype.queue = function(event, args, fn) {
        this._queue[event] = [fn, args];
        return this.emit(event, args);
      };

      return Base;

    })();
    zz["class"].positional = Positional = (function(superClass) {
      extend(Positional, superClass);

      function Positional(x1, y3) {
        this.x = x1 != null ? x1 : 0;
        this.y = y3 != null ? y3 : 0;
        Positional.__super__.constructor.apply(this, arguments);
      }

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
        return this.check();
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

      Ticker.prototype.framerate = 25;

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

      Game.prototype.defaults = {
        boards: [],
        ticker: {},
        renderer: {}
      };

      function Game() {
        Game.__super__.constructor.apply(this, arguments);
        zz.game = this;
        this.ticker = new zz["class"].ticker;
        this.ticker.on('tick', (function(_this) {
          return function() {
            return _this.renderer.render();
          };
        })(this));
        this.boards = [new Board];
        this.renderer = new CanvasRenderer(this);
        this.controller = new zz["class"].eventController(this.boards[0]);
      }

      Game.prototype.start = function() {
        return this.ticker.start();
      };

      return Game;

    })(Base);
    Renderer = (function(superClass) {
      extend(Renderer, superClass);

      Renderer.prototype.boardRenderer = function() {};

      function Renderer(game) {
        this.game = game;
        Renderer.__super__.constructor.apply(this, arguments);
        this.boards = [];
        $((function(_this) {
          return function() {
            var b, k, len, ref, results;
            ref = _this.game.boards;
            results = [];
            for (k = 0, len = ref.length; k < len; k++) {
              b = ref[k];
              results.push(_this.boards.push(new _this.boardRenderer(b)));
            }
            return results;
          };
        })(this));
      }

      Renderer.prototype.render = function() {
        var board, k, len, ref, results;
        ref = this.boards;
        results = [];
        for (k = 0, len = ref.length; k < len; k++) {
          board = ref[k];
          results.push(board.render());
        }
        return results;
      };

      return Renderer;

    })(Base);
    BoardRenderer = (function(superClass) {
      extend(BoardRenderer, superClass);

      function BoardRenderer(board1) {
        var b, k, len, ref;
        this.board = board1;
        BoardRenderer.__super__.constructor.apply(this, arguments);
        this.init();
        this.initBackground();
        ref = this.board.blocks;
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          this.initBlock(b);
        }
        this.initCursor(this.board.cursor);
        this.initScore();
      }

      BoardRenderer.prototype.init = function() {};

      BoardRenderer.prototype.initBackground = function() {};

      BoardRenderer.prototype.initBlock = function(block) {};

      BoardRenderer.prototype.initCursor = function(cursor) {};

      BoardRenderer.prototype.initScore = function() {};

      BoardRenderer.prototype.render = function() {
        var b, k, len, ref;
        ref = this.board.blocks;
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          this.renderBlock(b);
        }
        this.renderCursor(this.board.cursor);
        return this.renderScore();
      };

      BoardRenderer.prototype.renderBackground = function() {};

      BoardRenderer.prototype.renderBlock = function(block) {};

      BoardRenderer.prototype.renderCursor = function(cursor) {};

      BoardRenderer.prototype.renderScore = function() {};

      BoardRenderer.prototype.size = 50;

      BoardRenderer.prototype.offset = function() {
        return this.board.counter / this.board.speed * this.size;
      };

      BoardRenderer.prototype.toPos = function(pos) {
        return {
          x: pos.x * this.size,
          y: (this.board.height - pos.y - 1) * this.size
        };
      };

      return BoardRenderer;

    })(Base);
    CanvasBoardRenderer = (function(superClass) {
      extend(CanvasBoardRenderer, superClass);

      function CanvasBoardRenderer() {
        return CanvasBoardRenderer.__super__.constructor.apply(this, arguments);
      }

      CanvasBoardRenderer.prototype.colors = ['red', 'blue', 'green', 'purple', 'orange'];

      CanvasBoardRenderer.prototype.init = function() {
        $('#puzzle').attr({
          width: this.board.width * this.size,
          height: this.board.height * this.size
        });
        this.stage = new createjs.Stage('puzzle');
        this.board.on('swap', (function(_this) {
          return function(blocks) {
            return _this.swapAnimation(blocks);
          };
        })(this));
        this.board.on('match', (function(_this) {
          return function(matches) {
            return _this.matchAnimation(matches);
          };
        })(this));
        this.board.on('remove', (function(_this) {
          return function(block) {
            return _this.stage.removeChild(block.s);
          };
        })(this));
        return this.board.on('add', (function(_this) {
          return function(block) {
            return _this.initBlock(block);
          };
        })(this));
      };

      CanvasBoardRenderer.prototype.initBackground = function() {
        this.background = new createjs.Shape();
        this.background.graphics.beginFill('black').drawRect(0, 0, this.size * this.board.width, this.size * this.board.height);
        return this.stage.addChild(this.background);
      };

      CanvasBoardRenderer.prototype.initBlock = function(block) {
        var color;
        block.s = new createjs.Shape();
        this.release(block);
        color = this.colors[block.color];
        block.s.graphics.beginFill(color).drawRect(0, 0, this.size, this.size);
        return this.stage.addChild(block.s);
      };

      CanvasBoardRenderer.prototype.initCursor = function(cursor) {
        cursor.s = new createjs.Shape();
        cursor.s.graphics.beginStroke('white').drawRect(0, 0, this.size * 2, this.size);
        return this.stage.addChild(cursor.s);
      };

      CanvasBoardRenderer.prototype.render = function() {
        CanvasBoardRenderer.__super__.render.apply(this, arguments);
        return this.stage.update();
      };

      CanvasBoardRenderer.prototype.renderCursor = function(cursor) {
        var pos;
        pos = this.toPos(cursor);
        cursor.s.x = pos.x;
        return cursor.s.y = pos.y - this.offset();
      };

      CanvasBoardRenderer.prototype.renderBlock = function(b) {
        var pos;
        if (b.s == null) {
          this.initBlock(b);
        }
        if (!((b._stop != null) && !b._stop)) {
          return;
        }
        pos = this.toPos(b);
        b.s.x = pos.x;
        return b.s.y = pos.y - this.offset();
      };

      CanvasBoardRenderer.prototype.swapAnimation = function(blocks) {
        var b1, b2, ease, length, t1, t2;
        length = 100;
        b1 = blocks[0];
        b2 = blocks[1];
        this.hold(b1, b2);
        ease = createjs.Ease.linear;
        if (((b1 != null) && (b2 == null)) || ((b2 != null) && (b1 == null))) {
          console.log('ok');
          length += 100;
          ease = createjs.Ease.quadOut;
        }
        if (b1 != null) {
          t1 = createjs.Tween.get(b1.s).to({
            x: b1.s.x + this.size
          }, length, ease);
        }
        if (b2 != null) {
          t2 = createjs.Tween.get(b2.s).to({
            x: b2.s.x - this.size
          }, length, ease);
        }
        return (new createjs.Tween).wait(length).call((function(_this) {
          return function() {
            _this.release(b1, b2);
            return _this.board.done('swap');
          };
        })(this));
      };

      CanvasBoardRenderer.prototype.matchAnimation = function(matches) {
        var block, each, k, l, len, len1, length, set;
        length = 200;
        each = (function(_this) {
          return function(b) {
            return createjs.Tween.get(b.s).to({
              alpha: 0
            }, length).play();
          };
        })(this);
        for (k = 0, len = matches.length; k < len; k++) {
          set = matches[k];
          this.hold(set);
          for (l = 0, len1 = set.length; l < len1; l++) {
            block = set[l];
            each(block);
          }
        }
        return setTimeout((function(_this) {
          return function() {
            var len2, n;
            for (n = 0, len2 = matches.length; n < len2; n++) {
              set = matches[n];
              _this.release(set);
            }
            return _this.board.done('match');
          };
        })(this), length);
      };

      CanvasBoardRenderer.prototype.hold = function(obj) {
        var o;
        if (arguments.length > (1 != null)) {
          return (function() {
            var k, len, results;
            results = [];
            for (k = 0, len = arguments.length; k < len; k++) {
              o = arguments[k];
              results.push(this.hold(o));
            }
            return results;
          }).apply(this, arguments);
        }
        if (obj == null) {
          return;
        }
        if ((obj.length != null) && obj.length > (1 != null)) {
          return (function() {
            var k, len, results;
            results = [];
            for (k = 0, len = obj.length; k < len; k++) {
              o = obj[k];
              results.push(this.hold(o));
            }
            return results;
          }).call(this);
        }
        return obj._stop = true;
      };

      CanvasBoardRenderer.prototype.release = function(obj) {
        var o;
        if (arguments.length > (1 != null)) {
          return (function() {
            var k, len, results;
            results = [];
            for (k = 0, len = arguments.length; k < len; k++) {
              o = arguments[k];
              results.push(this.release(o));
            }
            return results;
          }).apply(this, arguments);
        }
        if (obj == null) {
          return;
        }
        if ((obj.length != null) && obj.length > (1 != null)) {
          return (function() {
            var k, len, results;
            results = [];
            for (k = 0, len = obj.length; k < len; k++) {
              o = obj[k];
              results.push(this.release(o));
            }
            return results;
          }).call(this);
        }
        return obj._stop = false;
      };

      return CanvasBoardRenderer;

    })(BoardRenderer);
    CanvasRenderer = (function(superClass) {
      extend(CanvasRenderer, superClass);

      function CanvasRenderer() {
        return CanvasRenderer.__super__.constructor.apply(this, arguments);
      }

      CanvasRenderer.prototype.boardRenderer = CanvasBoardRenderer;

      return CanvasRenderer;

    })(Renderer);
    zz["class"].controller = Controller = (function(superClass) {
      extend(Controller, superClass);

      Controller.prototype.board = {};

      Controller.state = null;

      function Controller(board1, state) {
        this.board = board1;
        this.state = state != null ? state : 'playing';
        Controller.__super__.constructor.apply(this, arguments);
      }

      Controller.prototype.keys = ['up', 'down', 'left', 'right', 'swap'];

      Controller.prototype.states = {
        playing: {
          up: function() {
            return this.board.cursor.move(0, 1);
          },
          down: function() {
            return this.board.cursor.move(0, -1);
          },
          left: function() {
            return this.board.cursor.move(-1, 0);
          },
          right: function() {
            return this.board.cursor.move(1, 0);
          },
          swap: function() {
            return this.board.swap();
          }
        }
      };

      Controller.prototype.dispatch = function(key, args) {
        if (this.states[this.state][key] != null) {
          this.states[this.state][key].call(this, args);
        }
        return zz.game.renderer.render();
      };

      return Controller;

    })(Base);
    zz["class"].eventController = EventController = (function(superClass) {
      extend(EventController, superClass);

      EventController.prototype.map = {
        37: 'left',
        38: 'up',
        39: 'right',
        40: 'down',
        32: 'swap'
      };

      function EventController(board1) {
        this.board = board1;
        EventController.__super__.constructor.call(this, this.board);
        $((function(_this) {
          return function() {
            return $('body').keydown(function(e) {
              var key;
              key = _this.map[e.which];
              if (key != null) {
                e.preventDefault(e);
                return _this.dispatch(key);
              }
            });
          };
        })(this));
      }

      return EventController;

    })(zz["class"].controller);
    zz["class"].board = Board = (function(superClass) {
      extend(Board, superClass);

      Board.prototype.defaults = {
        width: 8,
        height: 10,
        speed: 200,
        counter: 0,
        cursor: {},
        score: 0,
        blocks: []
      };

      function Board() {
        var b, k, l, len, ref, y;
        Board.__super__.constructor.apply(this, arguments);
        Object.defineProperty(this, 'grid', {
          get: (function(_this) {
            return function() {
              return _this.blockArray();
            };
          })(this)
        });
        for (y = k = -1; k <= 4; y = ++k) {
          ref = this.createRow(y);
          for (l = 0, len = ref.length; l < len; l++) {
            b = ref[l];
            this.blocks.push(b);
          }
        }
        this.cursor = new zz["class"].positional;
        this.cursor.limit([0, this.width - 2, 0, this.height - 2]);
        zz.game.ticker.on('tick', (function(_this) {
          return function() {
            _this.counter++;
            if (_this.counter > _this.speed) {
              _this.counter = 0;
              _this.pushRow();
            }
            return _this.update();
          };
        })(this));
      }

      Board.prototype.createRow = function(y) {
        var k, ref, results, x;
        results = [];
        for (x = k = 0, ref = this.width - 1; 0 <= ref ? k <= ref : k >= ref; x = 0 <= ref ? ++k : --k) {
          results.push(new ColorBlock(x, y));
        }
        return results;
      };

      Board.prototype.pushRow = function() {
        var b, k, l, len, len1, ref, ref1;
        ref = this.blocks;
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          b.y++;
        }
        this.cursor.move(0, 1);
        ref1 = this.createRow(-1);
        for (l = 0, len1 = ref1.length; l < len1; l++) {
          b = ref1[l];
          this.blocks.push(b);
        }
        return this.update();
      };

      Board.prototype.blockArray = function() {
        var b, k, len, ref;
        this._blockArray = [];
        this._blockArray.fill(this.width, this.height);
        ref = this.blocks;
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          if (b.y >= 0) {
            this._blockArray[b.x][b.y] = b;
          }
        }
        return this._blockArray;
      };

      Board.prototype.swap = function() {
        var b1, b2, x;
        b1 = this.grid[this.cursor.x][this.cursor.y];
        b2 = this.grid[this.cursor.x + 1][this.cursor.y];
        x = this.cursor.x;
        return this.queue('swap', [b1, b2], (function(_this) {
          return function() {
            if (b1 != null) {
              b1.x = x + 1;
            }
            if (b2 != null) {
              return b2.x = x;
            }
          };
        })(this));
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
          var k, ref, results;
          results = [];
          for (i = k = 0, ref = this.width - 1; 0 <= ref ? k <= ref : k >= ref; i = 0 <= ref ? ++k : --k) {
            results.push(this.grid[i][row]);
          }
          return results;
        }).call(this);
      };

      Board.prototype.getRows = function() {
        var i, k, ref, results;
        results = [];
        for (i = k = 0, ref = this.height - 1; 0 <= ref ? k <= ref : k >= ref; i = 0 <= ref ? ++k : --k) {
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
          var k, len, results;
          results = [];
          for (k = 0, len = blocks.length; k < len; k++) {
            b = blocks[k];
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
        if ((b1.matched != null) || (b2.matched != null)) {
          return false;
        }
        return b1.color === b2.color;
      };

      Board.prototype.getMatches = function() {
        var a, col, firstRow, k, l, len, len1, len2, len3, matches, n, p, ref, ref1, ref2, ref3, row;
        matches = [];
        firstRow = false;
        ref = this.getRows();
        for (k = 0, len = ref.length; k < len; k++) {
          row = ref[k];
          ref1 = this.checkRow(row);
          for (l = 0, len1 = ref1.length; l < len1; l++) {
            a = ref1[l];
            matches.push(a);
          }
        }
        ref2 = this.getColumns();
        for (n = 0, len2 = ref2.length; n < len2; n++) {
          col = ref2[n];
          ref3 = this.checkRow(col);
          for (p = 0, len3 = ref3.length; p < len3; p++) {
            a = ref3[p];
            matches.push(a);
          }
        }
        return matches;
      };

      Board.prototype.clearMatches = function(matches) {
        var k, len, m;
        for (k = 0, len = matches.length; k < len; k++) {
          m = matches[k];
          this.clearBlocks(m);
        }
        return this.score += matches.length;
      };

      Board.prototype.addBlocks = function(blocks) {
        var b, k, len;
        for (k = 0, len = blocks.length; k < len; k++) {
          b = blocks[k];
          this.emit('add', b);
          this.blocks.push(b);
        }
        return this._blockArray = null;
      };

      Board.prototype.clearBlocks = function(blocks) {
        var b, k, len;
        for (k = 0, len = blocks.length; k < len; k++) {
          b = blocks[k];
          this.emit('remove', b);
          this.blocks.remove(b);
        }
        return this._blockArray = null;
      };

      Board.prototype.update = function() {
        var matches;
        this.fallDown();
        zz.game.renderer.render();
        matches = this.getMatches();
        if (!(matches.length > 0)) {
          return;
        }
        return this.queue('match', matches, (function(_this) {
          return function() {
            _this.clearMatches(matches);
            return _this.update();
          };
        })(this));
      };

      Board.prototype.fallDown = function() {
        var col, i, k, len, ref, results;
        ref = this.getColumns();
        results = [];
        for (k = 0, len = ref.length; k < len; k++) {
          col = ref[k];
          col = col.sort(function(b1, b2) {
            var y1, y2;
            y1 = b1 != null ? b1.y : 1000;
            y2 = b2 != null ? b2.y : 1000;
            return y1 - y2;
          });
          results.push((function() {
            var l, ref1, results1;
            results1 = [];
            for (i = l = 0, ref1 = col.length - 1; 0 <= ref1 ? l <= ref1 : l >= ref1; i = 0 <= ref1 ? ++l : --l) {
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
        var col, k, l, ref, ref1, row, str;
        str = "";
        for (row = k = ref = this.height - 1; ref <= 0 ? k <= 0 : k >= 0; row = ref <= 0 ? ++k : --k) {
          str += "\n";
          for (col = l = 0, ref1 = this.width - 1; 0 <= ref1 ? l <= ref1 : l >= ref1; col = 0 <= ref1 ? ++l : --l) {
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

    })(zz["class"].base);
    zz["class"].block = Block = (function(superClass) {
      extend(Block, superClass);

      function Block(x1, y3) {
        this.x = x1;
        this.y = y3;
        this.active = true;
        Block.__super__.constructor.apply(this, arguments);
      }

      return Block;

    })(Positional);
    zz["class"].colorBlock = ColorBlock = (function(superClass) {
      extend(ColorBlock, superClass);

      ColorBlock.prototype.colors = 5;

      function ColorBlock(x1, y3, color1) {
        this.x = x1;
        this.y = y3;
        this.color = color1;
        ColorBlock.__super__.constructor.call(this, this.x, this.y);
        if (this.color == null) {
          this.color = Math.round(Math.random() * this.colors) % this.colors;
        }
      }

      return ColorBlock;

    })(Block);
    bigBlock = (function(superClass) {
      extend(bigBlock, superClass);

      function bigBlock(x1, y3, w1, h1) {
        this.x = x1;
        this.y = y3;
        this.w = w1;
        this.h = h1;
        bigBlock.__super__.constructor.call(this, this.x, this.y);
        this.active = false;
        this.blocks = [];
        forall(this.w, this.h, function(i, j) {
          return this.blocks.push(new Block(this.x + i, this.y + j));
        });
      }

      return bigBlock;

    })(Block);
    new zz["class"].game;
    return zz;
  });

}).call(this);
