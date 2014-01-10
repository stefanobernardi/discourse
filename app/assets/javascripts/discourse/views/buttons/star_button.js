/**
  A button for starring a topic

  @class StarButton
  @extends Discourse.ButtonView
  @namespace Discourse
  @module Discourse
**/
<<<<<<< HEAD:app/assets/javascripts/discourse/views/buttons/favorite_button.js
Discourse.FavoriteButton = Discourse.ButtonView.extend({
  classNames: ['favorite'],
  textKey: 'favorite.title',
  helpKeyBinding: 'controller.favoriteTooltipKey',
=======
Discourse.StarButton = Discourse.ButtonView.extend({
  classNames: ['star'],
  textKey: 'starred.title',
  helpKeyBinding: 'controller.starTooltipKey',
>>>>>>> upstream/master:app/assets/javascripts/discourse/views/buttons/star_button.js
  attributeBindings: ['disabled'],

  shouldRerender: Discourse.View.renderIfChanged('controller.starred'),

  click: function() {
    this.get('controller').send('toggleStar');
  },

  renderIcon: function(buffer) {
    buffer.push("<i class='fa fa-star " +
                 (this.get('controller.starred') ? ' starred' : '') +
                 "'></i>");
  }
});

