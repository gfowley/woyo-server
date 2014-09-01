
App = Ember.Application.create({
  LOG_TRANSITIONS: true
});

App.IndexRoute = Ember.Route.extend({
  beforeModel: function() {
    this.transitionTo('location', initial_location_id);
  }
});

App.Router.map(function() {
  this.resource('location', { path: '/location/:location_id' }); //, function() {
    // this.resource('items', { path: '/items' });
    // this.resource('ways', { path: '/ways' });
  // });
});

// location

App.LocationRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.find('location', params.location_id);
  }
});

App.LocationController = Ember.ObjectController.extend({
});

App.LocationView = Ember.View.extend({
  willAnimateIn : function () {
    console.log('location willAnimateIn');
    this.$().css("opacity", 0);
  },
  animateIn : function (done) {
    console.log('location animateIn');
    this.$().fadeTo(woyo.time.page_in, 1, done);
  },
  animateOut : function (done) {
    console.log('location animateIn');
    this.$().fadeTo(woyo.time.page_out, 0, done);
  }
})

App.Location = DS.Model.extend({
  name:         DS.attr(),
  description:  DS.attr(),
  items:        DS.hasMany('item', {async:true}),
  ways:         DS.hasMany('way',  {async:true})
});

// way

App.WayController = Ember.ObjectController.extend({
});

App.WayView = Ember.View.extend({
  willAnimateIn: function () {
    console.log('way willAnimateIn');
    this.$().css("opacity", 0);
  },
  animateIn: function (done) {
    console.log('way animateIn');
    this.$().fadeTo(woyo.time.page_in, 1, done);
  },
  animateOut: function (done) {
    console.log('way animateOut');
    this.$().fadeTo(woyo.time.page_out, 0, done);
  }
});

App.Way = DS.Model.extend({
  location:     DS.belongsTo('location'),
  name:         DS.attr(),
  description:  DS.attr()
});

// item

App.ItemRoute = Ember.Route.extend({
  beforeModel: function() {
    console.log("item beforeModel");
  },
  // model: function(params) {
  //   return this.store.find('item', params.item_id);
  // },
  afterModel: function() {
    console.log("item afterModel");
  }
});

App.ItemController = Ember.ObjectController.extend({
});

App.ItemView = Ember.View.extend({
  willAnimateIn: function () {
    console.log('item willAnimateIn');
    this.$().css("opacity", 0);
  },
  animateIn: function (done) {
    console.log('item animateIn');
    this.$().fadeTo(woyo.time.page_in, 1, done);
  },
  animateOut: function (done) {
    console.log('item animateOut');
    this.$().fadeTo(woyo.time.page_out, 0, done);
  }
});

App.Item = DS.Model.extend({
  location:     DS.belongsTo('location'),
  name:         DS.attr(),
  description:  DS.attr(),
  actions:      DS.hasMany('action', {async:false}),
  div_id:       function() { return 'item-' + this.get('id'); }.property('id'),
  didLoad: function() {
    console.log('item didLoad');
  }
});

// action

App.ActionController = Ember.ObjectController.extend({
  actions: {
    execute: function() {
      var that = this;
      this.get( 'execution' ).reload().then( function( execution ) {
        that.handle_execution( execution );
      }).then( function( execution) {
      });
    }
  },
  handle_execution: function( execution ) {
    var changes       = execution.get( 'changes' );
    var exec_action   = execution.get( 'action' );
    var exec_item     = exec_action.get( 'item' );
    var location      = exec_item.get( 'location' );
    for ( type in changes ) {
      if ( type == "item" ) {
        var items_changed = changes.item;
        for ( item_id in items_changed ) {
          var item = location.get( 'items' ).findProperty( 'id', item_id );
          if ( item ) {
            attrs_changed = items_changed[item_id];
            for ( attr_id in attrs_changed ) {
              var attr = item.get(attr_id);
              if ( attr ) {
                // howto set transitions for ember bound fields ?
                item.set( attr_id, attrs_changed[attr_id] );
              };
            };
          };
        };
      };
    };
    setTimeout(function(){ execution.set( 'describe', '' ); }, woyo.time.action_delay);
  }
});

App.ActionView = Ember.View.extend({
  willAnimateIn: function () {
    console.log('action willAnimateIn');
    this.$().css("opacity", 0);
  },
  animateIn: function (done) {
    console.log('action animateIn');
    this.$().fadeTo(woyo.time.page_in, 1, done);
  },
  animateOut: function (done) {
    console.log('action animateOut');
    this.$().fadeTo(woyo.time.page_out, 0, done);
  }
});

App.Action = DS.Model.extend({
  item:         DS.belongsTo('item'),
  name:         DS.attr(),
  description:  DS.attr(),
  execution:    DS.belongsTo('execution', {async:false})
});

// execution

App.ExecutionController = Ember.ObjectController.extend({
});

App.ExecutionView = Ember.View.extend({
  willAnimateIn: function () {
    console.log('execution willAnimateIn');
    this.$().css("opacity", 0);
  },
  animateIn: function (done) {
    console.log('execution animateIn');
    this.$().fadeTo(woyo.time.page_in, 1, done);
  },
  animateOut: function (done) {
    console.log('execution animateOut');
    this.$().fadeTo(woyo.time.page_out, 0, done);
  }
});

App.Execution = DS.Model.extend({
  action:       DS.belongsTo('action'),
  result:       DS.attr(),
  describe:     DS.attr(),
  changes:      DS.attr()
});

// functions

function hold(delay_time){
  var dfd = $.Deferred();
  setTimeout(function(){ dfd.resolve(); }, delay_time);
  return dfd.promise();
}

$(document).ready( function() {

  $("a.do").click( function() {
    owner = $("#" + $(this).parent().attr("owner_element"));
    $.getJSONj( $(this).attr("href") ).then(
      function(json) {
        // todo: handle multiple texts in describe array not just a string
        if ( json.describe.length > 0 ) {
          owner
          .children(".describe-actions")
          .text(json.describe)
          .slideDown(woyo.time.go_slide)
          .animate({opacity: 1}, woyo.time.go_fade)
          .delay(woyo.time.go_delay)
          .queue( function(next) {
          if ( json.changes.length > 0 ) {
              $("body").fadeOut(woyo.time.page_out, function() {
                window.location.reload(true);
              });
            };
            next();
          });
        } else {
          if ( json.changes.length > 0 ) {
            $("body").fadeOut(woyo.time.page_out, function() {
              window.location.reload(true);
            });
          };
        };
      }
    ); 
    return false;
  });

});

