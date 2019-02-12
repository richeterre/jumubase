import $ from "jquery";

$(document).ready(function() {
  $("#no-analytics-link").click(function() {
    Countly.q.push(["opt_out"]);
  });
});
