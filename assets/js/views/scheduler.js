import $ from 'jquery'
import 'jquery-ui/ui/widgets/sortable'
import 'jquery-ui/ui/widgets/resizable'

const scheduler = options => {
  const resizeConfig = {
    grid: [0, 10],
    minHeight: 40,
    handles: "s",
  }

  // Make schedule columns sortable
  $(".schedule-column").sortable({
    connectWith: ".schedule-column",
    update: function() {
      applyContestCategoryFilter()
      submitColumn(getColumnData($(this)))
    },
  })

  // Make spacers resizable
  $(".spacer").resizable(resizeConfig)

  // Let users add spacers to a schedule column
  $(".add-spacer-button").click(function(e) {
    e.preventDefault();
    const targetDate = $(e.target).attr("data-target-date")
    const spacer = $(`<div class="schedule-item spacer">Pause</div>`)
    $(`[data-date=${targetDate}]`).append(spacer.resizable(resizeConfig))
  })

  // Let users filter unscheduled list by contest category
  $("#cc-select").change(function() {
    applyContestCategoryFilter()
  })

  function applyContestCategoryFilter() {
    const ccId = $("#cc-select").val()
    const unscheduledItems = $('.schedule-column[data-date=""] .schedule-item')

    if (ccId) {
      // Show only items that match contest category id
      unscheduledItems.hide().filter(`[data-cc-id=${ccId}]`).show()
    } else {
      // Show all
      unscheduledItems.show()
    }
  }

  function submitColumn(data) {
    const { csrfToken, submitPath } = options

    $.ajax(submitPath, {
      method: "PATCH",
      beforeSend: function(xhr) {
        xhr.setRequestHeader("X-CSRF-Token", csrfToken)
      },
      data: {
        performances: data,
      },
    }).fail(function() {
      alert("Something went wrong") // TODO
    })
  }

  function getColumnData(column) {
    const date = $(column).attr("data-date")
    return $.makeArray(
      $(column).children(".schedule-item").map(function(index, item) {
        const id = $(item).attr("data-id")
        const time = timeFromIndex(index)
        return id && {
          id,
          stageId: date ? options.stageId : null,
          stageTime: date ? `${date}T${time}` : null,
        }
      })
    ).reduce((acc, item) => {
      acc[item.id] = item
      return acc
    }, {})
  }

  function timeFromIndex(index) {
    return `0${index}:00:00Z`
  }
}

// Make scheduler() available to global <script> tags
window.scheduler = scheduler
