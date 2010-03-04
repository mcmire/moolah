$(function() {
  $('#form').ajaxForm({
    url: "/transactions/destroy_multiple",
    beforeSubmit: function(data, form, options) {
      data["_method"] = "delete";
    }
  })
})