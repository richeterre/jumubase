import $ from "jquery";

$(".grouping-picker select").change(function() {
  this.form.submit();
});
