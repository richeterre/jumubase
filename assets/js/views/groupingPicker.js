import $ from "jquery";

$(".grouping-form select").change(function() {
  this.form.submit();
});
