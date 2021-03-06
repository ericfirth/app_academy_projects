TrelloClone.Views.BoardForm = Backbone.View.extend({
  template: JST["boards/form"],

  initialize: function() {
    this.listenTo(this.model, "sync", this.render)
  },

  events: {
    "submit": "submit"
  },

  render: function() {
    var content = this.template({ board: this.model });
    this.$el.html(content);
    return this;
  },

  submit: function (event) {
    event.preventDefault();
    var attrs = $(event.currentTarget).find("form").serializeJSON().board;
    this.model.set(attrs);

    var success = function () {
      this.collection.add(this.model, { merge: true })
      Backbone.history.navigate("", { trigger: true })
    }.bind(this)

    var that = this;
    var errors = function (model, response) {
      var $errorList = $("<ul>");
      debugger;
      response.responseJSON.forEach(function (error) {
        var $li = $("<li>");
        $li.html(error);
        $errorList.append($li);
        that.$el.prepend($errorList);
      })
    }

    this.model.save({}, {
      success: success,
      error: errors
    });
  }
});
