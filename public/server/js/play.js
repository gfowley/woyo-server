
App = Ember.Application.create({
  LOG_TRANSITIONS: true
});

App.IndexRoute = Ember.Route.extend({
  beforeModel: function() {
    this.transitionTo('location', initial_location_id);
  }
});

App.Router.map(function() {
  this.resource('location', { path: '/location/:location_id' });
});


// location

App.LocationController = Ember.ObjectController.extend({
  actions: {
    execute: function(action) {
      var that = this;
      action.get('execution').reload().then( function(execution) {
        // todo: assign model fields values from execution[:changes] instead of reloading whole location
        // howto set transitions for ember bound fields ?
        setTimeout(function(){
          that.get('model').reload();
          that.get('model').get('items').invoke('reload');
          that.get('model').get('ways' ).invoke('reload');
        }, woyo.time.action_delay);
      })
    }
  }
});

App.LocationView = Ember.View.extend({
    willAnimateIn : function () {
        this.$().css("opacity", 0);
    },
    animateIn : function (done) {
        this.$().fadeTo(woyo.time.page_in, 1, done);
    },
    animateOut : function (done) {
        this.$().fadeTo(woyo.time.page_out, 0, done);
    }
})

App.LocationRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.find('location', params.location_id);
  }
});

App.Location = DS.Model.extend({
  name:         DS.attr(),
  description:  DS.attr(),
  items:        DS.hasMany('item', {async:true}),
  ways:         DS.hasMany('way',  {async:true})
});

// other models

App.Item = DS.Model.extend({
  location:     DS.belongsTo('location'),
  name:         DS.attr(),
  description:  DS.attr(),
  actions:      DS.hasMany('action', {async:false}),
  div_id:       function() { return 'item-' + this.get('id'); }.property('id')
});

App.Way = DS.Model.extend({
  location:     DS.belongsTo('location'),
  name:         DS.attr(),
  description:  DS.attr()
});

App.Action = DS.Model.extend({
  item:         DS.belongsTo('item'),
  name:         DS.attr(),
  description:  DS.attr(),
  execution:    DS.belongsTo('execution', {async:false})
});

// execution

// App.ExecutionView = Ember.View.extend({
//   templateName: 'execution'
// })

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

