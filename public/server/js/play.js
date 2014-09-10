
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
  description:  DS.attr(),
  actions:      DS.hasMany('action', {async:false}),
  div_id:       function() { return 'way-' + this.get('id'); }.property('id')
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
      this.get( 'execution' ).reload().then( function( execution ) {
        var changes   = execution.get('changes');
        var result    = execution.get('result')
        var action    = execution.get('action');
        var owner     = action.get('owner');
        var location  = owner.get('location');
        // todo: make this work for all changes...
        // todo: transitions for changes to ember bound fields ?
        for ( change in changes ) {
          if ( change == "description" || change == "name" ) {
            location.set( change, changes[change] );
          }
          if ( change == "item" ) {
            var items_changed = changes.item;
            for ( item_id in items_changed ) {
              var item = location.get( 'items' ).findProperty( 'id', item_id );
              if ( item ) {
                attrs_changed = items_changed[item_id];
                for ( attr_id in attrs_changed ) {
                  var attr = item.get(attr_id);
                  if ( attr ) {
                    item.set( attr_id, attrs_changed[attr_id] );
                  };
                };
              };
            };
          };
          if ( change == "way" ) {
            var ways_changed = changes.way;
            for ( way_id in ways_changed ) {
              var way = location.get( 'ways' ).findProperty( 'id', way_id );
              if ( way ) {
                attrs_changed = ways_changed[way_id];
                for ( attr_id in attrs_changed ) {
                  var attr = way.get(attr_id);
                  if ( attr ) {
                    way.set( attr_id, attrs_changed[attr_id] );
                  };
                };
              };
            };
          };
        };
        if ( result.location ) {
          setTimeout(function(){ window.location.assign("/play"); }, woyo.time.go_delay);
        } else { 
          setTimeout(function(){ execution.set( 'display_describe', null ); }, woyo.time.action_delay);
        };
      }); 
    }
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
  way:          DS.belongsTo('way'),
  name:         DS.attr(),
  description:  DS.attr(),
  execution:    DS.belongsTo('execution', {async:false}),
  owner: function() { return this.get('item') || this.get('way'); }.property('item','way'),
  display_description: function() { return this.get('description') || this.get('name'); }.property('description','way')
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
  changes:      DS.attr(),
  display_describe: function(key, value, old) {
    // computed property to display describe lets me erase the displayed value without making the record dirty
    // a clean record permits reload from the server for subsequent action executions
    if ( arguments.length == 1 ) {
      return this.get('describe');
    } else {
      return value;
    }
  }.property('describe')
});

// functions

function hold(delay_time){
  var dfd = $.Deferred();
  setTimeout(function(){ dfd.resolve(); }, delay_time);
  return dfd.promise();
}

