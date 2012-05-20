// Generated by CoffeeScript 1.3.1
var App,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

App = (function(_super) {

  __extends(App, _super);

  App.name = 'App';

  function App() {
    return App.__super__.constructor.apply(this, arguments);
  }

  App.prototype.routes = {
    '': 'index',
    '/': 'index',
    ':id': 'show'
  };

  App.prototype.gotFirstRequest = false;

  App.prototype.status = 'index';

  App.prototype.initialize = function(options) {
    var loc;
    _.extend(this, options);
    loc = window.location.href;
    if (loc.match(/https:\/\//i)) {
      this.HOST_NAME = 'https://' + loc.replace(/https:\/\//, '').split('/')[0];
    } else {
      this.HOST_NAME = 'http://' + loc.replace(/http:\/\//, '').split('/')[0];
    }
    this.clientHeight = document.documentElement.clientHeight + 15;
    $('#wrapper').css({
      'height': this.clientHeight,
      'overflow-y': 'hidden'
    });
    $('.panel').css({
      'height': this.clientHeight,
      'overflow-y': 'hidden'
    });
    this.Main = new MainView();
    return this.Content = new ContentView();
  };

  App.prototype.index = function() {
    if (this.status === 'reverse') {
      this.Main.returnIndex();
    }
    this.status = 'index';
  };

  App.prototype.show = function(id) {
    if (this.status === 'index') {
      this.Main.showContent(id);
    } else {
      this.Content.render(id);
    }
  };

  return App;

})(Backbone.Router);

head.js('/assets/js/views/MainView.js', '/assets/js/views/ContentView.js');
