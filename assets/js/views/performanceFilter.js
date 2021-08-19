import $ from "jquery"

$(".filter-form select").change(function () {
  this.form.submit()
})
