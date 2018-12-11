import $ from 'jquery'
import 'jquery-ui/ui/widgets/sortable'
import 'jquery-ui/ui/widgets/resizable'

const resizeConfig = {
  grid: [0, 10],
  minHeight: 40,
  handles: "s",
}

$(".schedule-column").sortable({
  connectWith: ".schedule-column",
})

$(".spacer").resizable(resizeConfig)

$(".add-spacer-button").click(function (e) {
  e.preventDefault();
  const sortableId = $(e.target).attr("data-target")
  const spacer = $(`<div class="schedule-item spacer">Pause</div>`)
  $(`#${sortableId}`).append(spacer.resizable(resizeConfig))
})
