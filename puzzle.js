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
    var Base, Block, BlockGroup, Board, BoardRenderer, CanvasBoardRenderer, CanvasRenderer, ColorBlock, Controller, EventController, Game, Manager, MultiPlayer, Positional, Renderer, SinglePlayer, SoundController, Ticker, forall, zz;
    zz = {};
    zz["class"] = {};
    Array.prototype.remove = function(item) {
      if (this.indexOf(item) > -1) {
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
    Array.prototype.max = function() {
      return Math.max.apply(null, this);
    };
    Array.prototype.min = function() {
      return Math.min.apply(null, this);
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

      Base.prototype.done = function(event, args) {
        var fn;
        if (this._queue[event] == null) {
          return;
        }
        fn = this._queue[event];
        this._queue[event] = null;
        return fn.call(this, args);
      };

      Base.prototype.queue = function(event, args, fn) {
        this._queue[event] = fn;
        return this.emit(event, args);
      };

      return Base;

    })();
    zz["class"].positional = Positional = (function(superClass) {
      extend(Positional, superClass);

      function Positional(x1, y1) {
        this.x = x1 != null ? x1 : 0;
        this.y = y1 != null ? y1 : 0;
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

      Ticker.prototype.framerate = 60;

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
          })(this), 1000.0 / this.framerate);
        }
      };

      return Ticker;

    })(Base);
    zz.modes = {};
    zz.modes.single = SinglePlayer = (function(superClass) {
      extend(SinglePlayer, superClass);

      function SinglePlayer() {
        return SinglePlayer.__super__.constructor.apply(this, arguments);
      }

      SinglePlayer.prototype.initBoards = function() {
        return [new Board(0)];
      };

      return SinglePlayer;

    })(Base);
    zz.modes.multi = MultiPlayer = (function(superClass) {
      extend(MultiPlayer, superClass);

      function MultiPlayer() {
        return MultiPlayer.__super__.constructor.apply(this, arguments);
      }

      MultiPlayer.prototype.initBoards = function() {
        var b, boards, k, len;
        boards = [new Board(0), new Board(1)];
        boards[0].opponent = boards[1];
        boards[1].opponent = boards[0];
        for (k = 0, len = boards.length; k < len; k++) {
          b = boards[k];
          this.setUpEvents(b);
        }
        return boards;
      };

      MultiPlayer.prototype.setUpEvents = function(board) {
        board.on('score', function(score) {
          var h, w, x, y;
          console.log(score);
          if (score < 50) {
            return;
          }
          if (score >= 50) {
            w = 2;
            h = 2;
          }
          if (score >= 100) {
            w = 7;
            h = 1;
          }
          if (score >= 150) {
            w = 5;
            h = 2;
          }
          if (score >= 200) {
            w = 7;
            h = 2;
          }
          if (score >= 300) {
            w = 7;
            h = 3;
          }
          x = Math.random() * (board.width - w);
          x = Math.round(x);
          y = board.height - h;
          return board.opponent.addGroup(new BlockGroup(x, y, w, h));
        });
        return board.on('loss', function() {
          return board.opponent.stop();
        });
      };

      return MultiPlayer;

    })(Base);
    zz["class"].game = Game = (function(superClass) {
      extend(Game, superClass);

      Game.prototype.defaults = {
        boards: [],
        ticker: {},
        renderer: {}
      };

      function Game(mode) {
        var b;
        if (mode == null) {
          mode = 'multi';
        }
        Game.__super__.constructor.apply(this, arguments);
        zz.game = this;
        this.ticker = new zz["class"].ticker;
        this.ticker.on('tick', (function(_this) {
          return function() {
            return _this.loop();
          };
        })(this));
        this.mode = new zz.modes[mode];
        this.boards = this.mode.initBoards();
        this.renderer = new CanvasRenderer(this);
        this.controllers = (function() {
          var k, len, ref, results;
          ref = this.boards;
          results = [];
          for (k = 0, len = ref.length; k < len; k++) {
            b = ref[k];
            results.push(new EventController(b));
          }
          return results;
        }).call(this);
        this.soundsControllers = (function() {
          var k, len, ref, results;
          ref = this.boards;
          results = [];
          for (k = 0, len = ref.length; k < len; k++) {
            b = ref[k];
            results.push(new SoundController(b));
          }
          return results;
        }).call(this);
      }

      Game.prototype.initBoards = function() {};

      Game.prototype.start = function() {
        this.emit('start');
        return this.ticker.start();
      };

      Game.prototype.loop = function() {
        return this.renderer.render();
      };

      return Game;

    })(Base);
    Manager = (function() {
      function Manager() {
        this.menus = {};
        this.actions = {
          startSingle: (function(_this) {
            return function() {
              return _this.startGame('single');
            };
          })(this),
          vsFriend: (function(_this) {
            return function() {
              return _this.startGame('multi');
            };
          })(this)
        };
        $((function(_this) {
          return function() {
            return _this.setUpMenu();
          };
        })(this));
      }

      Manager.prototype.setUpMenu = function() {
        var that;
        that = this;
        this.menus = $('.menu');
        return this.menus.find('div').click(function() {
          var action, id;
          id = $(this).data('menu');
          if (id != null) {
            that.showMenu(id);
          }
          action = $(this).data('action');
          if (action != null) {
            return that.actions[action].call(that);
          }
        });
      };

      Manager.prototype.showMenu = function(id) {
        this.menus.hide();
        return $(".menu#" + id).show();
      };

      Manager.prototype.startGame = function(mode) {
        $('.main').hide();
        this.game = new Game(mode);
        return this.game.start();
      };

      Manager.prototype.endGame = function() {
        $('.main').show();
        return this.game.end();
      };

      return Manager;

    })();
    Renderer = (function(superClass) {
      extend(Renderer, superClass);

      Renderer.prototype.boardRenderer = function() {};

      function Renderer(game) {
        this.game = game;
        Renderer.__super__.constructor.apply(this, arguments);
        $('.puzzle').hide();
        this.boards = [];
        $((function(_this) {
          return function() {
            var b, i, k, len, ref, results;
            ref = _this.game.boards;
            results = [];
            for (i = k = 0, len = ref.length; k < len; i = ++k) {
              b = ref[i];
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

      BoardRenderer.prototype.size = 34;

      function BoardRenderer(board1) {
        var b, k, len, ref;
        this.board = board1;
        BoardRenderer.__super__.constructor.apply(this, arguments);
        this.init();
        this.initBackground();
        this.initCursor(this.board.cursor);
        ref = this.board.blocks;
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          this.initBlock(b);
        }
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

      CanvasBoardRenderer.prototype.colors = ['grey', 'blue', 'green', 'yellow', 'orange', 'red'];

      CanvasBoardRenderer.prototype.init = function() {
        $("#puzzle-" + this.board.id).attr({
          width: this.board.width * this.size,
          height: this.board.height * this.size
        }).show();
        this.stage = new createjs.Stage("puzzle-" + this.board.id);
        this.loadSprites();
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
        this.board.on('dispersal', (function(_this) {
          return function(args) {
            return _this.dispersalAnimation(args);
          };
        })(this));
        this.board.on('groupMove', (function(_this) {
          return function(args) {
            return _this.groupMoveAnimation(args);
          };
        })(this));
        this.board.on('scoring', (function(_this) {
          return function(args) {
            return _this.scoringAnimation(args);
          };
        })(this));
        return this.board.on('loss', (function(_this) {
          return function(args) {
            return _this.lossAnimation();
          };
        })(this));
      };

      CanvasBoardRenderer.prototype.initBackground = function() {
        this.background = new createjs.Shape();
        this.background.graphics.drawRect(0, 0, this.size * this.board.width, this.size * this.board.height);
        return this.stage.addChildAt(this.background, 0);
      };

      CanvasBoardRenderer.prototype.initBlock = function(block) {
        block.s = new createjs.Sprite(this.sprites[block.color], 'still');
        this.release(block);
        this.renderBlock(block);
        return this.stage.addChildAt(block.s, this.stage.children.length - 1);
      };

      CanvasBoardRenderer.prototype.initCursor = function(cursor) {
        cursor.s = new createjs.Shape();
        cursor.s.graphics.setStrokeStyle(2).beginStroke('white').drawRect(0, 0, this.size * 2, this.size);
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
        b.s.x = pos.x + 1;
        return b.s.y = pos.y - this.offset() + 1;
      };

      CanvasBoardRenderer.prototype.renderScore = function() {
        if (this.board.id === 0) {
          return $('#score').html(this.board.score);
        }
      };

      CanvasBoardRenderer.prototype.swapAnimation = function(blocks) {
        var b1, b2, ease, length, t1, t2;
        length = 100;
        b1 = blocks[0];
        b2 = blocks[1];
        this.hold(b1, b2);
        ease = createjs.Ease.linear;
        if (((b1 != null) && (b2 == null)) || ((b2 != null) && (b1 == null))) {
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
        return setTimeout((function(_this) {
          return function() {
            _this.release(b1, b2);
            return _this.board.done('swap');
          };
        })(this), length);
      };

      CanvasBoardRenderer.prototype.matchAnimation = function(matches) {
        var block, each, k, l, len, len1, length, set;
        length = 750;
        this.board.pause();
        each = (function(_this) {
          return function(b) {
            b.t = createjs.Tween.get(b.s).wait(length * .75).to({
              alpha: 0
            }, length * .25);
            return b.s.gotoAndPlay('matching');
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
            _this.board["continue"]();
            for (n = 0, len2 = matches.length; n < len2; n++) {
              set = matches[n];
              _this.release(set);
            }
            return _this.board.done('match');
          };
        })(this), length);
      };

      CanvasBoardRenderer.prototype.dispersalAnimation = function(args) {
        var b, fn, i, k, len, length, newBlocks, oldBlocks, perLength;
        oldBlocks = args.oldBlocks;
        newBlocks = args.newBlocks;
        perLength = 100;
        length = perLength * (newBlocks.length + 1);
        this.board.pause();
        this.hold(oldBlocks);
        for (i = k = 0, len = newBlocks.length; k < len; i = ++k) {
          b = newBlocks[i];
          fn = ((function(_this) {
            return function(b1, b2) {
              return function() {
                _this.initBlock(b1);
                return _this.stage.removeChild(b2);
              };
            };
          })(this))(b, oldBlocks[i]);
          setTimeout(fn, i * perLength);
        }
        return setTimeout((function(_this) {
          return function() {
            _this.board.done('dispersal');
            return _this.board["continue"]();
          };
        })(this), length);
      };

      CanvasBoardRenderer.prototype.groupMoveAnimation = function(args) {
        var b, distance, group, k, len, length, pos, ref;
        length = 300;
        group = args[0];
        distance = args[1];
        ref = group.blocks;
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          if (!b.s) {
            this.initBlock(b);
          }
          this.hold(b);
          pos = this.toPos(b).y + distance * this.size + this.offset();
          createjs.Tween.get(b.s).to({
            y: pos
          }, length, createjs.Ease.sinIn);
        }
        return setTimeout((function(_this) {
          return function() {
            var l, len1, ref1;
            ref1 = group.blocks;
            for (l = 0, len1 = ref1.length; l < len1; l++) {
              b = ref1[l];
              _this.release(b);
            }
            return _this.board.done('groupMove');
          };
        })(this), length);
      };

      CanvasBoardRenderer.prototype.scoringAnimation = function(args) {
        var chain, colors, pos, score, set, text;
        chain = args[0] - 1;
        score = args[1];
        set = args[2];
        colors = ["#fff", '#35B13F', '#F7DB01', '#F7040A', '#4AF7ED'];
        text = new createjs.Text("" + score, "20px Montserrat", colors[chain]);
        pos = this.toPos(set[0]);
        text.x = pos.x + this.size / 2;
        text.y = pos.y;
        createjs.Tween.get(text).to({
          y: pos.y - this.size * 2,
          alpha: 0.0
        }, 1000).call((function(_this) {
          return function() {
            return _this.stage.removeChild(text);
          };
        })(this));
        return this.stage.addChild(text);
      };

      CanvasBoardRenderer.prototype.lossAnimation = function() {
        var b, k, len, ref, results;
        ref = this.board.blocks;
        results = [];
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          this.hold(b);
          b.color = 0;
          this.stage.removeChild(b.s);
          results.push(this.initBlock(b));
        }
        return results;
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

      CanvasBoardRenderer.prototype.loadSprites = function() {
        var data, i;
        this.sprites = [];
        data = {
          frames: {
            width: 32,
            height: 32
          },
          animations: {
            still: 5,
            matching: {
              frames: ((function() {
                var k, results;
                results = [];
                for (i = k = 5; k >= 1; i = --k) {
                  results.push(i);
                }
                return results;
              })()).concat((function() {
                var k, results;
                results = [];
                for (i = k = 1; k <= 5; i = ++k) {
                  results.push(i);
                }
                return results;
              })()),
              speed: 0.75
            },
            matched: 0
          }
        };
        data.animations.still = 0;
        data.images = ["assets/sprites/grey.png"];
        this.sprites.push(new createjs.SpriteSheet(data));
        data.animations.still = 5;
        data.images = ["assets/sprites/green.png"];
        this.sprites.push(new createjs.SpriteSheet(data));
        data.images = ["assets/sprites/orange.png"];
        this.sprites.push(new createjs.SpriteSheet(data));
        data.images = ["assets/sprites/yellow.png"];
        this.sprites.push(new createjs.SpriteSheet(data));
        data.images = ["assets/sprites/blue.png"];
        this.sprites.push(new createjs.SpriteSheet(data));
        data.images = ["assets/sprites/purple.png"];
        return this.sprites.push(new createjs.SpriteSheet(data));
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

      Controller.prototype.keys = ['up', 'down', 'left', 'right', 'swap', 'advance'];

      Controller.prototype.states = {
        playing: {
          up: function() {
            return this.board.moveCursor(0, 1);
          },
          down: function() {
            return this.board.moveCursor(0, -1);
          },
          left: function() {
            return this.board.moveCursor(-1, 0);
          },
          right: function() {
            return this.board.moveCursor(1, 0);
          },
          swap: function() {
            return this.board.swap();
          },
          advance: function() {
            return this.board.counter += 30;
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

      EventController.prototype.MAPS = [
        {
          37: 'left',
          38: 'up',
          39: 'right',
          40: 'down',
          32: 'swap',
          13: 'advance'
        }, {
          65: 'left',
          87: 'up',
          68: 'right',
          83: 'down',
          81: 'swap'
        }
      ];

      function EventController(board1) {
        this.board = board1;
        EventController.__super__.constructor.call(this, this.board);
        this.map = this.MAPS[this.board.id];
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
    SoundController = (function(superClass) {
      extend(SoundController, superClass);

      SoundController.prototype.sounds = {
        click: 'click.wav',
        swoosh: 'swoosh.mp3',
        activate: 'activate.wav'
      };

      SoundController.prototype.events = {
        match: 'activate',
        cursorMove: 'click',
        swap: 'swoosh'
      };

      function SoundController(board1) {
        var key, ref, ref1, value;
        this.board = board1;
        ref = this.sounds;
        for (key in ref) {
          value = ref[key];
          createjs.Sound.registerSound("assets/sounds/" + value, key);
        }
        ref1 = this.events;
        for (key in ref1) {
          value = ref1[key];
          this.board.on(key, (function(id) {
            return function() {
              return createjs.Sound.play(id);
            };
          })(value));
        }
      }

      return SoundController;

    })(Base);
    zz["class"].board = Board = (function(superClass) {
      extend(Board, superClass);

      Board.prototype.width = 8;

      Board.prototype.height = 10;

      Board.prototype.speed = 60 * 15;

      Board.prototype.counter = 0;

      function Board(id1) {
        this.id = id1;
        Board.__super__.constructor.apply(this, arguments);
        this.blocks = [];
        this.groups = [];
        this.score = 0;
        this.stopped = false;
        Object.defineProperty(this, 'grid', {
          get: (function(_this) {
            return function() {
              return _this.blockArray();
            };
          })(this)
        });
        while (((function(_this) {
            return function() {
              var b, k, l, len, ref, y;
              _this.blocks = [];
              for (y = k = -1; k <= 2; y = ++k) {
                ref = _this.createRow(y);
                for (l = 0, len = ref.length; l < len; l++) {
                  b = ref[l];
                  _this.blocks.push(b);
                }
              }
              return _this.getMatches().length > 0;
            };
          })(this))()) {
          'do';
        }
        this.cursor = new zz["class"].positional;
        this.cursor.limit([0, this.width - 2, 0, this.height - 2]);
        zz.game.ticker.on('tick', (function(_this) {
          return function() {
            if (_this.stopped) {
              return;
            }
            if (!_this.paused) {
              _this.counter++;
            }
            if (_this.counter > _this.speed) {
              _this.counter = 0;
              _this.pushRow();
              return _this.speed *= 0.95;
            }
          };
        })(this));
      }

      Board.prototype.checkLoss = function() {
        var b, k, len, ref;
        ref = this.blocks;
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          if (b.y >= this.height - 1 && b.active) {
            return this.lose();
          }
        }
      };

      Board.prototype.lose = function() {
        this.stop();
        return this.emit('loss', this);
      };

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

      Board.prototype.addGroup = function(group) {
        this.groups.push(group);
        return this.addBlocks(group.blocks);
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
        if ((b1 != null) && !b1.canSwap) {
          return;
        }
        if ((b2 != null) && !b2.canSwap) {
          return;
        }
        return this.queue('swap', [b1, b2], (function(_this) {
          return function() {
            if (b1 != null) {
              b1.x = x + 1;
            }
            if (b2 != null) {
              b2.x = x;
            }
            return _this.update();
          };
        })(this));
      };

      Board.prototype.moveCursor = function(x, y) {
        this.emit('cursorMove');
        return this.cursor.move(x, y);
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
        var b, blocks, grid;
        grid = this.grid;
        blocks = [];
        blocks.push(grid[block.x][block.y + 1]);
        blocks.push(grid[block.x][block.y - 1]);
        if (grid[block.x - 1] != null) {
          blocks.push(grid[block.x - 1][block.y]);
        }
        if (grid[block.x + 1] != null) {
          blocks.push(grid[block.x + 1][block.y]);
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
        if (!(b1.color && b2.color)) {
          return false;
        }
        return b1.color === b2.color;
      };

      Board.prototype.getMatches = function() {
        var a, col, k, l, len, len1, len2, len3, matches, n, p, ref, ref1, ref2, ref3, row;
        matches = [];
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
        var k, len, m, results;
        results = [];
        for (k = 0, len = matches.length; k < len; k++) {
          m = matches[k];
          this.clearBlocks(m);
          results.push(this.checkDisperse(m));
        }
        return results;
      };

      Board.prototype.scoreMatches = function(chain, matches) {
        var k, len, score, set, setScore;
        score = 0;
        for (k = 0, len = matches.length; k < len; k++) {
          set = matches[k];
          setScore = chain * set.length * 10;
          this.emit('scoring', [chain, setScore, set]);
          score += setScore;
        }
        return score;
      };

      Board.prototype.addBlocks = function(blocks) {
        var b, k, len;
        for (k = 0, len = blocks.length; k < len; k++) {
          b = blocks[k];
          this.emit('add', b);
          this.blocks.push(b);
        }
        return this.update();
      };

      Board.prototype.clearBlocks = function(blocks) {
        var b, k, len, results;
        if (!blocks.length) {
          blocks = [blocks];
        }
        results = [];
        for (k = 0, len = blocks.length; k < len; k++) {
          b = blocks[k];
          this.emit('remove', b);
          results.push(this.blocks.remove(b));
        }
        return results;
      };

      Board.prototype.checkDisperse = function(blocks) {
        var b, block, k, l, len, len1, ref;
        for (k = 0, len = blocks.length; k < len; k++) {
          block = blocks[k];
          ref = this.getAdjacent(block);
          for (l = 0, len1 = ref.length; l < len1; l++) {
            b = ref[l];
            if (b.group != null) {
              return this.disperseGroup(b.group);
            }
          }
        }
      };

      Board.prototype.disperseGroup = function(group) {
        var block, newBlocks;
        if (!this.groups.indexOf(group > -1)) {
          return;
        }
        this.groups.remove(group);
        newBlocks = (function() {
          var k, len, ref, results;
          ref = group.blocks;
          results = [];
          for (k = 0, len = ref.length; k < len; k++) {
            block = ref[k];
            results.push(new ColorBlock(block.x, block.y));
          }
          return results;
        })();
        return this.queue('dispersal', {
          oldBlocks: group.blocks,
          newBlocks: newBlocks
        }, (function(_this) {
          return function() {
            _this.addBlocks(newBlocks);
            return _this.clearBlocks(group.blocks);
          };
        })(this));
      };

      Board.prototype.update = function(chain) {
        var block, k, l, len, len1, matches, score, set;
        if (chain == null) {
          chain = 1;
        }
        this._blockArray = null;
        this.fallDown();
        this.checkLoss();
        if (zz.game.renderer.render != null) {
          zz.game.renderer.render();
        }
        matches = this.getMatches();
        if (matches.length === 0) {
          this.emit('chainComplete', chain);
          return;
        }
        for (k = 0, len = matches.length; k < len; k++) {
          set = matches[k];
          for (l = 0, len1 = set.length; l < len1; l++) {
            block = set[l];
            block.canSwap = false;
          }
        }
        score = this.scoreMatches(chain, matches);
        this.emit('score', score);
        this.score += score;
        return this.queue('match', matches, (function(_this) {
          return function() {
            _this.clearMatches(matches);
            _this.update(chain + 1);
            return _this.emit('matchComplete', matches);
          };
        })(this));
      };

      Board.prototype.fallDown = function() {
        var block, d, distances, grid, group, i, j, k, l, len, len1, minDist, n, p, ref, ref1, ref2, ref3, results, y;
        grid = this.grid;
        for (i = k = 0, ref = grid.length - 1; 0 <= ref ? k <= ref : k >= ref; i = 0 <= ref ? ++k : --k) {
          for (j = l = 1, ref1 = grid[i].length - 1; 1 <= ref1 ? l <= ref1 : l >= ref1; j = 1 <= ref1 ? ++l : --l) {
            if (!grid[i][j]) {
              continue;
            }
            if (grid[i][j].group != null) {
              continue;
            }
            y = j;
            while ((grid[i][y] != null) && (grid[i][y - 1] == null) && y > 0) {
              grid[i][y - 1] = grid[i][y];
              grid[i][y - 1].y--;
              grid[i][y] = null;
              y--;
            }
          }
        }
        ref2 = this.groups;
        results = [];
        for (n = 0, len = ref2.length; n < len; n++) {
          group = ref2[n];
          distances = [];
          ref3 = group.bottom;
          for (p = 0, len1 = ref3.length; p < len1; p++) {
            block = ref3[p];
            d = 1;
            while ((this.grid[block.x][block.y - d] == null) && block.y - d > 0) {
              d++;
            }
            distances.push(d);
          }
          minDist = distances.min() - 1;
          if (!group.active) {
            results.push(this.queue('groupMove', [group, minDist], (function(_this) {
              return function() {
                group.moveAll(0, -minDist);
                group.activate();
                return _this.checkLoss();
              };
            })(this)));
          } else {
            results.push(group.moveAll(0, -minDist));
          }
        }
        return results;
      };

      Board.prototype.pause = function() {
        return this.paused = true;
      };

      Board.prototype["continue"] = function() {
        return this.paused = false;
      };

      Board.prototype.stop = function() {
        return this.stopped = true;
      };

      return Board;

    })(zz["class"].base);
    zz["class"].block = Block = (function(superClass) {
      extend(Block, superClass);

      function Block(x1, y1) {
        this.x = x1;
        this.y = y1;
        this.canSwap = true;
        this.color = false;
        this.active = true;
        Block.__super__.constructor.apply(this, arguments);
      }

      return Block;

    })(Positional);
    zz["class"].colorBlock = ColorBlock = (function(superClass) {
      extend(ColorBlock, superClass);

      ColorBlock.prototype.colors = 5;

      function ColorBlock(x1, y1, color) {
        this.x = x1;
        this.y = y1;
        this.color = color;
        ColorBlock.__super__.constructor.call(this, this.x, this.y);
        this.color = Math.round(Math.random() * this.colors) % this.colors + 1;
      }

      return ColorBlock;

    })(Block);
    BlockGroup = (function(superClass) {
      extend(BlockGroup, superClass);

      function BlockGroup(x1, y1, w1, h1) {
        this.x = x1;
        this.y = y1;
        this.w = w1;
        this.h = h1;
        BlockGroup.__super__.constructor.call(this, this.x, this.y);
        this.blocks = [];
        this.bottom = [];
        this.active = false;
        forall(this.w, this.h, (function(_this) {
          return function(i, j) {
            var b;
            b = new Block(_this.x + i, _this.y + j);
            b.group = _this;
            b.canSwap = false;
            b.color = 0;
            b.active = false;
            if (j === 0) {
              _this.bottom.push(b);
            }
            return _this.blocks.push(b);
          };
        })(this));
      }

      BlockGroup.prototype.moveAll = function(x, y) {
        var b, k, len, ref, results;
        ref = this.blocks;
        results = [];
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          results.push(b.move(x, y));
        }
        return results;
      };

      BlockGroup.prototype.activate = function() {
        var b, k, len, ref;
        ref = this.blocks;
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          b.active = true;
        }
        return this.active = true;
      };

      return BlockGroup;

    })(Positional);
    new Manager();
    return zz;
  });

}).call(this);
