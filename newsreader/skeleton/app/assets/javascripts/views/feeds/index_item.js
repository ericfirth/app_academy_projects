NewsReader.Views.IndexItem = Backbone.View.extend({
  template: JST["feeds/index_item"],

  tagName: "li",

  render: function() {
    var content = this.template({ feed: this.model });
    this.$el.html(content);

    return this;
  }

});
