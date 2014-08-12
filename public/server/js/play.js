
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
  description:  DS.attr()
});

App.Way = DS.Model.extend({
  location:     DS.belongsTo('location'),
  name:         DS.attr(),
  description:  DS.attr()
});

