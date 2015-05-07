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
    var Base, Block, BlockGroup, Board, BoardRenderer, BoardSoundController, CanvasBoardRenderer, CanvasRenderer, ComputerController, Controller, Game, GrayBlock, KeyListener, Manager, MusicController, PlayerController, Positional, Renderer, STATE, SoundController, Ticker, forall, zz;
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
        this.useQueue = true;
        ref = this.defaults;
        for (key in ref) {
          value = ref[key];
          this[key] = value;
        }
      }

      Base.prototype.on = function(event, fn, state) {
        var s;
        if (state == null) {
          state = '';
        }
        if (typeof state === 'object' && (state.length != null)) {
          return (function() {
            var k, len, results;
            results = [];
            for (k = 0, len = state.length; k < len; k++) {
              s = state[k];
              results.push(this.on(event, fn, s));
            }
            return results;
          }).call(this);
        }
        if (this._events['' + event + state] == null) {
          this._events['' + event + state] = [];
        }
        return this._events['' + event + state].push(fn);
      };

      Base.prototype.unbind = function(event, fn) {
        if (fn == null) {
          return this._events[event] = [];
        }
      };

      Base.prototype.emit = function(event, args, state) {
        var fn, k, len, ref;
        if (state == null) {
          state = false;
        }
        if (!state) {
          this.emit('' + event + zz.game.state, args, true);
        }
        if (this._events[event] == null) {
          return false;
        }
        ref = this._events[event];
        for (k = 0, len = ref.length; k < len; k++) {
          fn = ref[k];
          fn.call(this, args);
        }
        return true;
      };

      Base.prototype.done = function(event, args) {
        var fn;
        if (this._queue[event] == null) {
          return;
        }
        fn = this._queue[event].shift();
        if (fn == null) {
          return;
        }
        return fn.call(this, args);
      };

      Base.prototype.queue = function(event, args, fn) {
        if (this._queue[event] == null) {
          this._queue[event] = [];
        }
        this._queue[event].push(fn);
        this.emit(event, args);
        if (!this.useQueue) {
          return this.done(event);
        }
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
    Ticker = (function(superClass) {
      extend(Ticker, superClass);

      Ticker.prototype.elapsed = 0;

      function Ticker(framerate) {
        if (framerate == null) {
          framerate = 60;
        }
        Ticker.__super__.constructor.apply(this, arguments);
        this.framerate = framerate;
        this.running = false;
      }

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
    STATE = {
      MENU: 'menu',
      PLAYING: 'playing',
      OVER: 'over',
      PAUSED: 'paused'
    };
    Game = (function(superClass) {
      extend(Game, superClass);

      Game.prototype.defaults = {
        boards: [],
        ticker: {},
        renderer: {}
      };

      Game.settings = {
        players: 1,
        music: 1.0,
        sound: 1.0,
        computer: true
      };

      function Game() {
        Game.__super__.constructor.apply(this, arguments);
        zz.game = this;
        this.state = STATE.MENU;
        this.ticker = new Ticker();
        this.ticker.on('tick', (function(_this) {
          return function() {
            return _this.loop();
          };
        })(this));
        this.key = new KeyListener;
        this.music = new MusicController;
        this.sound = new SoundController;
        this.manager = new Manager;
      }

      Game.prototype.setState = function(state) {
        this.state = state;
        return this.emit('state', state);
      };

      Game.prototype.initBoards = function() {
        var b, k, len, ref, results;
        this.boards = [];
        this.boards.push(new Board(0));
        new PlayerController(this.boards[0]);
        if (this.settings.players === 2) {
          this.boards.push(new Board(1));
          this.boards[0].opponent = this.boards[1];
          this.boards[1].opponent = this.boards[0];
          if (this.settings.computer) {
            new ComputerController(this.boards[1]);
          } else {
            new PlayerController(this.boards[1]);
          }
        }
        ref = this.boards;
        results = [];
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          results.push(b.on('lose', (function(_this) {
            return function() {
              console.log(_this.state);
              return _this.setState(STATE.OVER);
            };
          })(this)));
        }
        return results;
      };

      Game.prototype.start = function(settings) {
        var b, k, len, ref;
        this.settings = $.extend(Game.settings, settings, true);
        this.initBoards();
        this.renderer = new CanvasRenderer(this);
        ref = this.boards;
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          new BoardSoundController(b);
        }
        this.ticker.start();
        this.setState(STATE.PLAYING);
        return this.emit('start');
      };

      Game.prototype["continue"] = function() {
        this.emit('continue');
        this.ticker.start();
        return this.setState(STATE.PLAYING);
      };

      Game.prototype.stop = function() {
        this.emit('stop');
        this.ticker.stop();
        delete this.boards;
        delete this.ticker;
        return this.setState(STATE.MENU);
      };

      Game.prototype.pause = function() {
        this.emit('pause');
        this.ticker.stop();
        return this.setState(STATE.PAUSED);
      };

      Game.prototype.restart = function() {
        this.stop();
        return this.start();
      };

      Game.prototype.loop = function() {
        return this.renderer.render();
      };

      return Game;

    })(Base);
    Manager = (function() {
      function Manager() {
        this.settings = {};
        this.menus = {};
        this.actions = {
          startSingle: (function(_this) {
            return function() {
              return zz.game.start({
                players: 1
              });
            };
          })(this),
          vsFriend: (function(_this) {
            return function() {
              return zz.game.start({
                players: 2,
                computer: false
              });
            };
          })(this),
          vsComputer: (function(_this) {
            return function() {
              return zz.game.start({
                players: 2,
                computer: true
              });
            };
          })(this),
          "continue": (function(_this) {
            return function() {
              return zz.game["continue"]();
            };
          })(this),
          exit: (function(_this) {
            return function() {
              return zz.game.stop();
            };
          })(this),
          fullscreen: (function(_this) {
            return function() {
              return $(document).toggleFullScreen();
            };
          })(this)
        };
        zz.game.key.on('ESC', (function(_this) {
          return function() {
            return zz.game.pause();
          };
        })(this), STATE.PLAYING);
        zz.game.key.on('ESC', (function(_this) {
          return function() {
            return zz.game["continue"]();
          };
        })(this), STATE.PAUSED);
        zz.game.key.on('DOWN', (function(_this) {
          return function() {
            _this.highlight(1);
            return zz.game.sound.play('click');
          };
        })(this), [STATE.MENU, STATE.PAUSED]);
        zz.game.key.on('UP', (function(_this) {
          return function() {
            _this.highlight(-1);
            return zz.game.sound.play('click');
          };
        })(this), [STATE.MENU, STATE.PAUSED]);
        zz.game.key.on('SPACE', (function(_this) {
          return function() {
            _this.highlight(0);
            return zz.game.sound.play('click');
          };
        })(this), [STATE.MENU, STATE.PAUSED]);
        zz.game.key.on('RETURN', (function(_this) {
          return function() {
            _this.highlight(0);
            return zz.game.sound.play('click');
          };
        })(this), [STATE.MENU, STATE.PAUSED]);
        zz.game.key.on('RETURN', (function(_this) {
          return function() {
            return zz.game.stop();
          };
        })(this), STATE.OVER);
        zz.game.key.on('ESC', (function(_this) {
          return function() {
            return zz.game.stop();
          };
        })(this), STATE.OVER);
        zz.game.on('start', (function(_this) {
          return function() {};
        })(this));
        zz.game.on('pause', (function(_this) {
          return function() {
            return _this.showMenu('pause');
          };
        })(this));
        zz.game.on('continue', (function(_this) {
          return function() {
            return _this.showMenu(null);
          };
        })(this));
        zz.game.on('stop', (function(_this) {
          return function() {
            return window.location = '/';
          };
        })(this));
        zz.game.on('state', (function(_this) {
          return function(state) {
            $('body').attr('class', '');
            return $('body').addClass("state-" + state);
          };
        })(this));
        this.setUpMenu();
      }

      Manager.prototype.setUpMenu = function() {
        var that;
        that = this;
        this.menus = $('.menu');
        this.menus.find('div').click(function() {
          var action, id;
          id = $(this).data('menu');
          if (id != null) {
            that.showMenu(id);
          }
          action = $(this).data('action');
          if (action != null) {
            return that.actions[action].call(that);
          }
        }).mouseover(function() {
          return that.highlight($(this));
        });
        return this.showMenu('main');
      };

      Manager.prototype.showMenu = function(id) {
        var menu;
        $('.menu.active').removeClass('active');
        if (id == null) {
          return;
        }
        menu = $(".menu#" + id).addClass('active');
        return this.highlight(menu.children('div').first());
      };

      Manager.prototype.highlight = function(index) {
        var item;
        if (index === 0 && $('.highlight').length !== 0) {
          $('.highlight').click();
          return;
        }
        if ((index != null) && (index.jquery != null)) {
          $('.highlight').removeClass('highlight');
          index.addClass('highlight');
          return;
        }
        item = $('.menu.active .highlight');
        if (item.length === 0) {
          this.highlight($('.menu.active').children('div').first());
          return;
        }
        if (index === 1 && item.next('div').length > 0) {
          return this.highlight(item.next('div'));
        }
        if (index === -1 && item.prev('div').length > 0) {
          return this.highlight(item.prev('div'));
        }
      };

      return Manager;

    })();
    Renderer = (function(superClass) {
      extend(Renderer, superClass);

      Renderer.prototype.boardRenderer = function() {};

      function Renderer() {
        var b, i, k, len, ref;
        Renderer.__super__.constructor.apply(this, arguments);
        $('.puzzle').hide();
        this.boards = [];
        ref = zz.game.boards;
        for (i = k = 0, len = ref.length; k < len; i = ++k) {
          b = ref[i];
          this.boards.push(new this.boardRenderer(b));
        }
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
        return this.renderCursor(this.board.cursor);
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

      CanvasBoardRenderer.prototype.init = function() {
        this.id = "puzzle-" + this.board.id;
        $("#" + this.id).attr({
          width: this.board.width * this.size,
          height: this.board.height * this.size
        }).show();
        this.stage = new createjs.Stage(this.id);
        this.loadSprites();
        this.animate('start');
        this.animate('swap');
        this.animate('match');
        this.animate('lose');
        this.animate('win');
        this.animate('dispersal');
        this.animate('addGroup');
        this.board.on('remove', (function(_this) {
          return function(b) {
            return _this.stage.removeChild(b);
          };
        })(this));
        this.board.on('scoreChange', (function(_this) {
          return function() {
            return _this.renderScore();
          };
        })(this));
        this.board.on('logScore', (function(_this) {
          return function(score) {
            if (!(score >= 50)) {
              return;
            }
            $('<div></div>', {
              "class": 'color'
            }).insertAfter($('.combos').children().first()).html(score);
            if ($('.combos').length > 20) {
              return $('.combos').children().last.remove();
            }
          };
        })(this));
        this.renderScore();
        this.text = null;
        this.initCookies();
        return this.board.on('refreshHigh', (function(_this) {
          return function() {
            return _this.initCookies();
          };
        })(this));
      };

      CanvasBoardRenderer.prototype.initCookies = function() {
        var cookie, k, len, ref, results, score;
        cookie = Cookies('highscores');
        if (cookie == null) {
          Cookies('highscores', JSON.stringify([]), {
            expires: Infinity
          });
        }
        this.scores = $.parseJSON(cookie);
        $('#highscores').html('');
        ref = this.scores;
        results = [];
        for (k = 0, len = ref.length; k < len; k++) {
          score = ref[k];
          results.push($('<tr></tr>').append("<td>" + score.name + "<td>").append("<td class='color'>" + score.score + "<td>").appendTo('#highscores'));
        }
        return results;
      };

      CanvasBoardRenderer.prototype.initScore = function() {
        $("#player-" + this.board.id + " .scoreboard").show();
        if (this.board.id > 0) {
          return $('.combos').hide();
        }
      };

      CanvasBoardRenderer.prototype.initBlock = function(block) {
        var animation;
        animation = 'still';
        if (block.y < 0) {
          animation = 'matched';
        }
        block.s = new createjs.Sprite(this.sprites[block.color], animation);
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
        if (b.y === -1 && (b._activated == null) && this.offset() >= this.size - 1) {
          b.s.gotoAndPlay('activate');
          b._activated = true;
        }
        pos = this.toPos(b);
        b.s.x = pos.x + 1;
        return b.s.y = pos.y - this.offset() + 1;
      };

      CanvasBoardRenderer.prototype.renderScore = function() {
        $("#player-" + this.board.id + " .score").html(this.board.score);
        return $("#player-" + this.board.id + " .speed").html(this.board.speedLevel);
      };

      CanvasBoardRenderer.prototype.animate = function(event) {
        return this.board.on(event, (function(_this) {
          return function() {
            return _this[event + 'Animation'].apply(_this, arguments);
          };
        })(this));
      };

      CanvasBoardRenderer.prototype.after = function(length, fn) {
        return setTimeout(fn, length);
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
        return this.after(length, (function(_this) {
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
        this.render();
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
        return this.after(length, (function(_this) {
          return function() {
            var len2, n;
            _this.board["continue"]();
            for (n = 0, len2 = matches.length; n < len2; n++) {
              set = matches[n];
              _this.release(set);
            }
            return _this.board.done('match');
          };
        })(this));
      };

      CanvasBoardRenderer.prototype.dispersalAnimation = function(args) {
        var b, fn, i, k, len, length, newBlocks, oldBlocks, perLength;
        oldBlocks = args.oldBlocks;
        newBlocks = args.newBlocks;
        perLength = 100;
        length = perLength * (newBlocks.length + 1);
        this.hold(oldBlocks);
        for (i = k = 0, len = newBlocks.length; k < len; i = ++k) {
          b = newBlocks[i];
          fn = ((function(_this) {
            return function(b) {
              return function() {
                return _this.initBlock(b);
              };
            };
          })(this))(b);
          setTimeout(fn, i * perLength);
        }
        return this.after(length, (function(_this) {
          return function() {
            var l, len1;
            for (l = 0, len1 = oldBlocks.length; l < len1; l++) {
              b = oldBlocks[l];
              _this.stage.removeChild(b.s);
            }
            return _this.board.done('dispersal');
          };
        })(this));
      };

      CanvasBoardRenderer.prototype.addGroupAnimation = function(group) {
        var b, k, len, length, ref, tmp;
        length = 1000;
        ref = group.blocks;
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          if (!b.s) {
            this.initBlock(b);
          }
          this.renderBlock(b);
          this.hold(b);
          tmp = b.s.y;
          b.s.y = tmp - this.size * this.board.height - group.h;
          createjs.Tween.get(b.s).to({
            y: tmp
          }, length, createjs.Ease.bounceOut);
        }
        return this.after(length, (function(_this) {
          return function() {
            var l, len1, ref1, results;
            ref1 = group.blocks;
            results = [];
            for (l = 0, len1 = ref1.length; l < len1; l++) {
              b = ref1[l];
              results.push(_this.release(b));
            }
            return results;
          };
        })(this));
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

      CanvasBoardRenderer.prototype.loseAnimation = function() {
        var b, k, len, ref;
        ref = this.board.blocks;
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          b.color = 0;
          this.stage.removeChild(b.s);
          this.initBlock(b);
          b.s.gotoAndPlay('lost');
        }
        if (this.board.opponent != null) {
          return this.message("Defeat");
        } else {
          return this.message("Game\nOver");
        }
      };

      CanvasBoardRenderer.prototype.winAnimation = function() {
        return this.message("Victory!");
      };

      CanvasBoardRenderer.prototype.message = function(message) {
        var text;
        this.clearText();
        text = new createjs.Text(message, "40px '8BIT WONDER'", 'white');
        text.shadow = new createjs.Shadow("#000000", 9, 9, 0);
        text.y = 100;
        text.x = this.stage.getBounds().width / 2 - text.getBounds().width / 2;
        this.stage.addChild(text);
        return this.text = text;
      };

      CanvasBoardRenderer.prototype.clearText = function() {
        if (this.text != null) {
          return this.stage.removeChild(this.text);
        }
      };

      CanvasBoardRenderer.prototype.startAnimation = function() {
        this.message("Get\nReady");
        console.log('ahere');
        return setTimeout((function(_this) {
          return function() {
            _this.clearText();
            _this.board.done('start');
            return console.log('here');
          };
        })(this), 1500);
      };

      CanvasBoardRenderer.prototype.loadSprites = function() {
        var data;
        this.sprites = [];
        data = {
          frames: {
            width: 32,
            height: 32
          },
          animations: {
            still: 5,
            fillIn: [0, 1, 2, 3, 4, 5],
            fillOut: [5, 4, 3, 2, 1, 0],
            matching: {
              frames: [0, 1, 2, 3, 4, 5, 4, 3, 2, 1],
              speed: 0.75
            },
            matched: 0,
            lost: {
              frames: [5, 4, 3, 2, 1, 0],
              next: 'matched',
              speed: 0.1
            },
            activate: {
              frames: [0, 1, 2, 3, 4, 5],
              next: 'still',
              speed: 0.5
            }
          }
        };
        data.images = ["assets/sprites/grey.png"];
        this.sprites.push(new createjs.SpriteSheet(data));
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
    KeyListener = (function(superClass) {
      extend(KeyListener, superClass);

      KeyListener.prototype.MAP = {
        LEFT: 37,
        UP: 38,
        RIGHT: 39,
        DOWN: 40,
        SPACE: 32,
        RETURN: 13,
        ESC: 27,
        SHIFT: 16
      };

      function KeyListener() {
        KeyListener.__super__.constructor.apply(this, arguments);
        this.listening = true;
        $((function(_this) {
          return function() {
            return $('body').keydown(function(e) {
              if (!_this.listening) {
                return;
              }
              if (_this.emit(e.which)) {
                return e.preventDefault(e);
              }
            });
          };
        })(this));
      }

      KeyListener.prototype.on = function(key, fn, state) {
        if (this.MAP[key] != null) {
          key = this.MAP[key];
        }
        return KeyListener.__super__.on.call(this, key, fn, state);
      };

      KeyListener.prototype.start = function() {
        return this.listening = false;
      };

      KeyListener.prototype.stop = function() {
        return this.listening = true;
      };

      return KeyListener;

    })(Base);
    Controller = (function(superClass) {
      extend(Controller, superClass);

      Controller.prototype.board = {};

      function Controller(board1) {
        this.board = board1;
        Controller.__super__.constructor.apply(this, arguments);
      }

      Controller.prototype.keys = ['up', 'down', 'left', 'right', 'swap', 'advance'];

      Controller.prototype.events = {
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
      };

      Controller.prototype.dispatch = function(key, args) {
        if (zz.game.state !== STATE.PLAYING) {
          return;
        }
        if (this.events[key] != null) {
          return this.events[key].call(this, args);
        }
      };

      return Controller;

    })(Base);
    PlayerController = (function(superClass) {
      extend(PlayerController, superClass);

      PlayerController.prototype.keyMaps = [
        {
          LEFT: 'left',
          UP: 'up',
          RIGHT: 'right',
          DOWN: 'down',
          SPACE: 'swap',
          ESC: 'exit'
        }, {
          65: 'left',
          87: 'up',
          68: 'right',
          83: 'down',
          SHIFT: 'swap'
        }
      ];

      function PlayerController(board1) {
        var key, ref, value;
        this.board = board1;
        PlayerController.__super__.constructor.call(this, this.board);
        this.map = this.keyMaps[this.board.id];
        ref = this.map;
        for (key in ref) {
          value = ref[key];
          zz.game.key.on(key, ((function(_this) {
            return function(v) {
              return function() {
                return _this.dispatch(v);
              };
            };
          })(this))(value));
        }
      }

      return PlayerController;

    })(Controller);
    ComputerController = (function(superClass) {
      extend(ComputerController, superClass);

      ComputerController.prototype.speed = 500;

      ComputerController.prototype.levels = 1;

      function ComputerController(board1) {
        var t;
        this.board = board1;
        ComputerController.__super__.constructor.call(this, this.board);
        t = new Ticker(4);
        t.on('tick', (function(_this) {
          return function() {
            return _this.evaluate();
          };
        })(this));
        t.start();
        this.board.on('update', (function(_this) {
          return function() {
            if (_this.target === 'wait') {
              return _this.target = null;
            }
          };
        })(this));
        this.target = null;
        this.lastTarget = null;
      }

      ComputerController.prototype.evaluateBoard = function(board, level, top) {
        var b, best, k, l, len, len1, p1, p2, ref, swaps, tmp, trials;
        if (level == null) {
          level = 0;
        }
        if (top == null) {
          top = true;
        }
        trials = [];
        swaps = [];
        ref = board.blocks;
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          if (!b.canSwap) {
            continue;
          }
          if (b.y < 0) {
            continue;
          }
          p1 = {
            x: b.x,
            y: b.y
          };
          p2 = {
            x: b.x - 1,
            y: b.y
          };
          if (b.color === 0) {
            p1.score = -10000 * b.y;
          }
          if (swaps.indexOf(p1) === -1 && p1.x < board.width - 2) {
            swaps.push(p1);
          }
          if (swaps.indexOf(p2) === -1 && p2.x > 0) {
            swaps.push(p2);
          }
        }
        for (l = 0, len1 = swaps.length; l < len1; l++) {
          b = swaps[l];
          tmp = board.clone();
          tmp.useQueue = false;
          tmp.cursor.x = b.x;
          tmp.cursor.y = b.y;
          if (!tmp.swap()) {
            continue;
          }
          if (b.score != null) {
            tmp.score += b.score;
          }
          if (b.y > 5) {
            tmp.score -= b.y * 10;
          }
          if (b.y > 8) {
            tmp.score -= b.y * 10000;
          }
          if (level > 0) {
            best = this.evaluateBoard(tmp, level - 1, false);
            tmp.score += best.score * 0.9;
          }
          trials.push({
            x: b.x,
            y: b.y,
            score: tmp.score + Math.random()
          });
        }
        trials.sort(function(a, b) {
          return a.score - b.score;
        });
        if (top) {
          return trials;
        }
        return trials.pop();
      };

      ComputerController.prototype.evaluate = function() {
        var best, trials;
        if (this.target) {
          return this.goto(this.target);
        }
        trials = this.evaluateBoard(this.board, 1);
        best = trials.pop();
        return this.target = best;
      };

      ComputerController.prototype.goto = function(target) {
        var diff;
        if (target.x == null) {
          return;
        }
        diff = {
          x: target.x - this.board.cursor.x,
          y: target.y - this.board.cursor.y
        };
        if (diff.x === 0 && diff.y === 0) {
          this.dispatch('swap');
          this.lastTarget = this.target;
          this.target = null;
          return;
        }
        if (diff.x < 0) {
          this.dispatch('left');
        } else if (diff.x > 0) {
          this.dispatch('right');
        } else if (diff.y > 0) {
          this.dispatch('up');
        } else if (diff.y < 0) {
          this.dispatch('down');
        }
      };

      return ComputerController;

    })(Controller);
    SoundController = (function(superClass) {
      extend(SoundController, superClass);

      SoundController.prototype.sounds = {
        click: 'click.wav',
        slide: 'slide.wav',
        match: 'match0.wav'
      };

      function SoundController() {
        var key, ref, value;
        ref = this.sounds;
        for (key in ref) {
          value = ref[key];
          createjs.Sound.registerSound("assets/sounds/" + value, key);
        }
      }

      SoundController.prototype.play = function(sound, settings) {
        if (settings == null) {
          settings = {};
        }
        return createjs.Sound.play(sound);
      };

      return SoundController;

    })(Base);
    MusicController = (function(superClass) {
      extend(MusicController, superClass);

      MusicController.prototype.initialize = function() {
        var f, files, k, len;
        files = [
          {
            id: 'intro',
            src: 'intro.mp3'
          }, {
            id: 'mid',
            src: 'mid.mp3'
          }
        ];
        for (k = 0, len = files.length; k < len; k++) {
          f = files[k];
          f.src = 'assets/music/' + f.src;
        }
        createjs.Sound.alternateExtensions = ["mp3"];
        return createjs.Sound.registerSounds(files);
      };

      function MusicController() {
        this.initialize();
        this.current = null;
        zz.game.on('start', (function(_this) {
          return function() {
            _this.current = createjs.Sound.play('intro');
            return _this.current.on('complete', function() {
              _this.current = createjs.Sound.play('mid');
              _this.current.loop = true;
              return _this.current.volume = zz.game.settings.music;
            });
          };
        })(this));
        zz.game.on('pause', (function(_this) {
          return function() {
            return _this.current.volume = zz.game.settings.music / 2.0;
          };
        })(this));
        zz.game.on('continue', (function(_this) {
          return function() {
            return _this.current.volume = zz.game.settings.music;
          };
        })(this));
      }

      return MusicController;

    })(Base);
    BoardSoundController = (function(superClass) {
      extend(BoardSoundController, superClass);

      BoardSoundController.prototype.events = [
        {
          on: 'match',
          sound: 'match',
          settings: {
            volume: 0.5
          }
        }, {
          on: 'cursorMove',
          sound: 'click',
          settings: {
            volume: 0.5
          }
        }, {
          on: 'swap',
          sound: 'slide',
          settings: {
            volume: 0.5
          }
        }
      ];

      function BoardSoundController(board1) {
        var event, k, len, ref;
        this.board = board1;
        ref = this.events;
        for (k = 0, len = ref.length; k < len; k++) {
          event = ref[k];
          this.board.on(event.on, ((function(_this) {
            return function(e) {
              return function() {
                return createjs.Sound.play(e.sound, e.settings);
              };
            };
          })(this))(event));
        }
      }

      return BoardSoundController;

    })(Base);
    zz["class"].board = Board = (function(superClass) {
      extend(Board, superClass);

      Board.prototype.width = 8;

      Board.prototype.height = 12;

      function Board(id1, clone) {
        this.id = id1;
        if (clone == null) {
          clone = false;
        }
        Board.__super__.constructor.apply(this, arguments);
        this.blocks = [];
        this.groups = [];
        this.score = 0;
        this.opponent = null;
        this.lost = false;
        this.counter = 0;
        this.speed = 60 * 15;
        this.speedLevel = 1;
        this.speedCounter = 0;
        Object.defineProperty(this, 'grid', {
          get: (function(_this) {
            return function() {
              return _this.blockArray();
            };
          })(this)
        });
        if (!clone) {
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
        }
        this.cursor = new Positional;
        this.cursor.limit([0, this.width - 2, 0, this.height - 2]);
        if (clone) {
          return;
        }
        zz.game.ticker.on('tick', (function(_this) {
          return function() {
            return _this.tick();
          };
        })(this));
        this.updateGrid();
        this.paused = true;
        setTimeout((function(_this) {
          return function() {
            return _this.queue('start', [], function() {
              return _this.paused = false;
            });
          };
        })(this), 100);
      }

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

      Board.prototype.pause = function() {
        return this.paused = true;
      };

      Board.prototype["continue"] = function() {
        return this.paused = false;
      };

      Board.prototype.tick = function() {
        if (this.paused) {
          return;
        }
        this.counter++;
        this.speedCounter++;
        if (this.counter > this.speed) {
          this.counter = 0;
          this.pushRow();
        }
        if (this.speedCounter % (60 * 15) === 0) {
          this.speedLevel++;
          this.speed *= 0.95;
          return this.emit('scoreChange');
        }
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
        return this.updateGrid();
      };

      Board.prototype.createRow = function(y) {
        var k, ref, results, x;
        results = [];
        for (x = k = 0, ref = this.width - 1; 0 <= ref ? k <= ref : k >= ref; x = 0 <= ref ? ++k : --k) {
          results.push(new Block(x, y));
        }
        return results;
      };

      Board.prototype.addGroup = function(group) {
        var b, k, len, ref;
        this.groups.push(group);
        ref = group.blocks;
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          this.blocks.push(b);
        }
        this.updateGrid();
        return this.emit('addGroup', group);
      };

      Board.prototype.addBlocks = function(blocks) {
        var b, k, len;
        for (k = 0, len = blocks.length; k < len; k++) {
          b = blocks[k];
          this.blocks.push(b);
        }
        return this.updateGrid();
      };

      Board.prototype.checkLoss = function() {
        var b, k, len, ref;
        ref = this.blocks;
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          if (b.y >= this.height - 1 && b.canLose) {
            return this.lose();
          }
        }
      };

      Board.prototype.lose = function() {
        this.pause();
        this.emit('lose', this);
        if (this.opponent != null) {
          this.opponent.pause();
        }
        if (this.opponent != null) {
          this.opponent.win();
        }
        return this.writeCookie();
      };

      Board.prototype.win = function() {
        this.emit('win');
        return this.writeCookie();
      };

      Board.prototype.swap = function() {
        var b1, b2, x;
        x = this.cursor.x;
        b1 = this.grid[x][this.cursor.y];
        b2 = this.grid[x + 1][this.cursor.y];
        if (!((b1 != null) || (b2 != null))) {
          return false;
        }
        if ((b1 != null) && !b1.canSwap) {
          return false;
        }
        if ((b2 != null) && !b2.canSwap) {
          return false;
        }
        this.queue('swap', [b1, b2], (function(_this) {
          return function() {
            if (b1 != null) {
              b1.x = x + 1;
            }
            if (b2 != null) {
              b2.x = x;
            }
            return _this.updateGrid();
          };
        })(this));
        return true;
      };

      Board.prototype.moveCursor = function(x, y) {
        this.emit('cursorMove');
        return this.cursor.move(x, y);
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
        if (!(b1.canMatch && b2.canMatch)) {
          return false;
        }
        if (!(b1.color && b2.color)) {
          return false;
        }
        return b1.color === b2.color;
      };

      Board.prototype.clearMatches = function(matches) {
        var k, len, m;
        for (k = 0, len = matches.length; k < len; k++) {
          m = matches[k];
          this.clearBlocks(m);
          this.checkDisperse(m);
        }
        return this.scoreMatches(matches);
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
            results.push(new Block(block.x, block.y));
          }
          return results;
        })();
        this.pause();
        return this.queue('dispersal', {
          oldBlocks: group.blocks,
          newBlocks: newBlocks
        }, (function(_this) {
          return function() {
            _this.addBlocks(newBlocks);
            _this.clearBlocks(group.blocks);
            return _this["continue"]();
          };
        })(this));
      };

      Board.prototype.scoreMatches = function(matches) {
        var k, len, mult, score, set;
        score = 0;
        mult = 1;
        matches = matches.sort(function(a, b) {
          return a.length - b.length;
        });
        for (k = 0, len = matches.length; k < len; k++) {
          set = matches[k];
          score += mult * set.length * 10;
          mult += 1;
        }
        return score;
      };

      Board.prototype.updateGrid = function(chain, score) {
        var block, k, l, len, len1, matches, set;
        if (chain == null) {
          chain = 0;
        }
        if (score == null) {
          score = 0;
        }
        this.fallDown();
        this.groupFallDown();
        this.checkLoss();
        matches = this.getMatches();
        if (matches.length === 0 && score === 0) {
          this.emit('update');
          return;
        } else if (matches.length === 0 && score > 0) {
          this.score += score * chain;
          this.sendBlocks(score * chain);
          this.emit('update');
          return;
        }
        for (k = 0, len = matches.length; k < len; k++) {
          set = matches[k];
          for (l = 0, len1 = set.length; l < len1; l++) {
            block = set[l];
            block.canSwap = false;
            block.canMatch = false;
          }
        }
        return this.queue('match', matches, (function(_this) {
          return function() {
            score += _this.clearMatches(matches);
            return _this.updateGrid(chain + 1, score);
          };
        })(this));
      };

      Board.prototype.fallDown = function() {
        var grid, i, j, k, ref, results, y;
        grid = this.grid;
        results = [];
        for (i = k = 0, ref = grid.length - 1; 0 <= ref ? k <= ref : k >= ref; i = 0 <= ref ? ++k : --k) {
          results.push((function() {
            var l, ref1, results1;
            results1 = [];
            for (j = l = 1, ref1 = grid[i].length - 1; 1 <= ref1 ? l <= ref1 : l >= ref1; j = 1 <= ref1 ? ++l : --l) {
              if (!grid[i][j]) {
                continue;
              }
              if (grid[i][j].group != null) {
                continue;
              }
              y = j;
              results1.push((function() {
                var results2;
                results2 = [];
                while ((grid[i][y] != null) && (grid[i][y - 1] == null) && y > 0) {
                  grid[i][y - 1] = grid[i][y];
                  grid[i][y - 1].y--;
                  grid[i][y] = null;
                  results2.push(y--);
                }
                return results2;
              })());
            }
            return results1;
          })());
        }
        return results;
      };

      Board.prototype.groupFallDown = function() {
        var block, d, distances, grid, group, k, l, len, len1, minDist, ref, ref1, results;
        grid = this.grid;
        ref = this.groups;
        results = [];
        for (k = 0, len = ref.length; k < len; k++) {
          group = ref[k];
          distances = [];
          ref1 = group.bottom;
          for (l = 0, len1 = ref1.length; l < len1; l++) {
            block = ref1[l];
            d = 1;
            while ((this.grid[block.x][block.y - d] == null) && block.y - d > 0) {
              d++;
            }
            distances.push(d);
          }
          minDist = distances.min() - 1;
          group.moveAll(0, -minDist);
          results.push(group.activate());
        }
        return results;
      };

      Board.prototype.sendBlocks = function(score) {
        var dim, h, shapes, thresh, w, x, y;
        this.emit('logScore', score);
        this.emit('scoreChange');
        if (this.opponent == null) {
          return;
        }
        shapes = {
          100: [8, 1],
          200: [8, 2],
          300: [8, 3]
        };
        for (thresh in shapes) {
          dim = shapes[thresh];
          if (score >= Number(thresh)) {
            w = dim[0];
            h = dim[1];
          }
        }
        x = Math.random() * (this.opponent.width - w);
        x = Math.round(x);
        y = this.opponent.height - h;
        return this.opponent.addGroup(new BlockGroup(x, y, w, h));
      };

      Board.prototype.clone = function() {
        var b, board, k, len, ref;
        board = new Board(2, true);
        board.blocks = [];
        ref = this.blocks;
        for (k = 0, len = ref.length; k < len; k++) {
          b = ref[k];
          board.blocks.push(b.clone());
        }
        return board;
      };

      Board.prototype.writeCookie = function() {
        if (zz.game.settings.computer && this.id === 1) {
          return;
        }
        if (this.cookie != null) {
          return;
        }
        this.cookie = true;
        return setTimeout((function(_this) {
          return function() {
            var name, score, scores;
            scores = $.parseJSON(Cookies('highscores'));
            if (scores.length < 10 || _this.score > scores[scores.length - 1].score) {
              name = prompt('Highscore! Please enter your name:');
              score = _this.score;
              scores.push({
                name: name,
                score: score
              });
              scores.sort(function(a, b) {
                return b.score - a.score;
              });
              scores = scores.slice(0, 10);
              Cookies('highscores', JSON.stringify(scores, {
                expires: Infinity
              }));
              return _this.emit('refreshHigh');
            }
          };
        })(this), 2000);
      };

      return Board;

    })(zz["class"].base);
    zz["class"].block = Block = (function(superClass) {
      extend(Block, superClass);

      Block.prototype.colors = 5;

      function Block(x1, y1) {
        this.x = x1;
        this.y = y1;
        this.canSwap = true;
        this.canLose = true;
        this.canMatch = true;
        this.color = this.randomColor();
        Block.__super__.constructor.call(this, this.x, this.y);
      }

      Block.prototype.randomColor = function() {
        return Math.round(Math.random() * this.colors) % this.colors + 1;
      };

      Block.prototype.clone = function() {
        var b;
        b = new Block();
        b.color = this.color;
        b.x = this.x;
        b.y = this.y;
        return b;
      };

      return Block;

    })(Positional);
    GrayBlock = (function(superClass) {
      extend(GrayBlock, superClass);

      function GrayBlock(x1, y1, group1) {
        this.x = x1;
        this.y = y1;
        this.group = group1;
        GrayBlock.__super__.constructor.call(this, this.x, this.y);
        this.color = 0;
        this.canSwap = false;
        this.canMatch = false;
        this.canLose = false;
      }

      return GrayBlock;

    })(Block);
    BlockGroup = (function(superClass) {
      extend(BlockGroup, superClass);

      function BlockGroup(x1, y1, w1, h1) {
        this.x = x1;
        this.y = y1;
        this.w = w1;
        this.h = h1;
        BlockGroup.__super__.constructor.call(this, this.x, this.y);
        this.canLose = false;
        this.blocks = [];
        this.bottom = [];
        forall(this.w, this.h, (function(_this) {
          return function(i, j) {
            var b;
            b = new GrayBlock(_this.x + i, _this.y + j, _this);
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
          b.canLose = true;
        }
        return this.canLose = true;
      };

      return BlockGroup;

    })(Positional);
    $(function() {
      return zz.game = new Game();
    });
    return zz;
  });

}).call(this);
