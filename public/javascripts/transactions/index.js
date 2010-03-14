$(function() {
  $('#delete_checked').click(function(event) {
    if (confirm(this.title)) {
      var input = document.createElement("input");
      input.name = "_method";
      input.value = "delete";
      this.form.appendChild(input);
      this.form.action = "/transactions/destroy_multiple"
    } else {
      event.preventDefault()
    }
  });
  
  $('#delete_all').click(function() {
    var all = this;
    $('.delete_box').each(function() {
      this.checked = all.checked;
    });
  })
})