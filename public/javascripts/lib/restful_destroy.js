// Here's how to make use of restful_destroy:
//
// 1. Ensure that you have a route set up for your resource's delete action:
// 
//      map.resources :whatever, :member => { :delete => :get }
//
//    This page should have a confirmation message and a form that sends a DELETE to /destroy.
//
// 2. In your view, instead of saying:
//
//      link_to("whatever", foo_path(foo), :method => :delete, :confirm => "Are you sure?"),
//
//    say this instead:
//
//      link_to("whatever", delete_foo_path(foo), :class => 'delete', :title => "Are you sure?")
//
// 3. Include restful_destroy.js in your view that has the delete link, and all links with
//    a class of 'delete' will be automatically changed so that clicking on them will show
//    a confirm popup box and DELETE to /destroy. If Javascript is not enabled then this
//    falls back to the 'delete' action.

$(function() {
  $("a.delete").click(function(event) {
    var msg = this.title;
    if (confirm(msg)) {
      var action = this.href.replace(/\/delete/, "/destroy");
      
      var f = document.createElement("form");
      f.style.display = "none";
      f.method = "post";
      f.action = action;
      
      var m = document.createElement("input");
      m.type = "hidden";
      m.name = "_method";
      m.value = "delete";
      
      f.appendChild(m);
      this.parentNode.appendChild(f);
      f.submit();
    }
    event.preventDefault();
  })
  
  $('input[type=submit].delete').click(function(event) {
    if (confirm(this.title)) return true;
    else event.preventDefault();
  });
})