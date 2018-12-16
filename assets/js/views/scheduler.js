import $ from 'jquery'
import 'jquery-ui/ui/widgets/sortable'
import 'jquery-ui/ui/widgets/resizable'
import { isEmpty } from 'lodash'

const scheduler = options => {
  const gridHeight = pixelsFromMinutes(5)

  const resizeConfig = {
    grid: [0, gridHeight],
    minHeight: gridHeight,
    handles: "s",
    resize: function(e, ui) {
      $(this).setMinutesFromHeight(ui.size.height)
    },
  }

  // Set up unscheduled column
  $('.schedule-column[data-date=""]').sortable({
    connectWith: ".schedule-column",
    receive: function() {
      applyContestCategoryFilter()
      submitColumn($(this).getColumnData())
    },
  })

  // Set up columns that have dates
  $('.schedule-column[data-date!=""]').sortable({
    connectWith: ".schedule-column",
    update: function() {
      const data = $(this).getColumnData()
      !isEmpty(data) && submitColumn(data)
    },
  })

  // Make spacers resizable
  $(".spacer").resizable(resizeConfig)

  // Let users add spacers to a schedule column
  $(".add-spacer-button").click(function(e) {
    e.preventDefault();
    const targetDate = $(e.target).attr("data-target-date")
    createSpacer().appendTo(`[data-date=${targetDate}]`)
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

  function timeFromIndex(index) {
    return `0${index}:00:00Z`
  }

  function pixelsFromMinutes(minutes) {
    return minutes * options.pixelsPerMinute
  }

  function minutesFromPixels(pixels) {
    return pixels / options.pixelsPerMinute
  }

  function createSpacer() {
    const spacerHeight = resizeConfig.minHeight
    return $(`<div class="schedule-item spacer"><span class="text-muted"></span></div>`)
      .css("height", spacerHeight)
      .setMinutesFromHeight(spacerHeight)
      .resizable(resizeConfig)
  }

  $.fn.extend({
    setMinutesFromHeight: function(height) {
      const minutes = minutesFromPixels(height)
      return $(this)
      .children("span").html(`Pause (${minutes} min)`).parent()
      .attr("data-minutes", minutes)
    },
    getColumnData: function() {
      const date = $(this).attr("data-date")
      return $.makeArray(
        $(this).children(".schedule-item").map(function(index, item) {
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
    },
  })
}

// Make scheduler() available to global <script> tags
window.scheduler = scheduler
