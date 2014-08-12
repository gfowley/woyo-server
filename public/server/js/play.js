
App = Ember.Application.create({
  LOG_TRANSITIONS: true
});

App.Router.map(function() {
  // this.resource('locations');
  this.resource('location', { path: '/location/:location_id' });
});

App.IndexRoute = Ember.Route.extend({
  beforeModel: function() {
    this.transitionTo('location', initial_location_id);
  }
});

// App.LocationsRoute = Ember.Route.extend({
//   model: function() {
//     return this.store.find('location');
//   }
// });

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
  li_id:        function() { return 'action-item-' + this.get('item').id + '-' + this.get('id'); }.property('id'),
  a_id:         function() { return 'do-item-'     + this.get('item').id + '-' + this.get('id'); }.property('id'),
  a_href:       function() { return '/do/item/'    + this.get('item').id + '/' + this.get('id'); }.property('id')
});

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

