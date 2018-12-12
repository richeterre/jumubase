import $ from 'jquery'
import 'jquery-ui/ui/widgets/sortable'
import 'jquery-ui/ui/widgets/resizable'

const resizeConfig = {
  grid: [0, 10],
  minHeight: 40,
  handles: "s",
}

// Make schedule columns sortable
$(".schedule-column").sortable({
  connectWith: ".schedule-column",
  receive: function() {
    applyContestCategoryFilter()
  },
})

// Make spacers resizable
$(".spacer").resizable(resizeConfig)

// Let users add spacers to a schedule column
$(".add-spacer-button").click(function (e) {
  e.preventDefault();
  const sortableId = $(e.target).attr("data-target")
  const spacer = $(`<div class="schedule-item spacer">Pause</div>`)
  $(`#${sortableId}`).append(spacer.resizable(resizeConfig))
})

// Let users filter unscheduled list by contest category
$("#cc-select").change(function() {
  applyContestCategoryFilter()
})

function applyContestCategoryFilter() {
  const ccId = $("#cc-select").val()
  const unscheduledItems = $("#schedule-column-unscheduled .schedule-item")

  if (ccId) {
    // Show only items that match contest category id
    unscheduledItems.hide().filter(`[data-cc-id=${ccId}]`).show()
  } else {
    // Show all
    unscheduledItems.show()
  }
}
