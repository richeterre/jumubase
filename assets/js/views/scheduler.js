import $ from 'jquery'
import { DateTime } from 'luxon'
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
      submitColumn($(this).parent(".schedule-column"))
    },
  }

  // Set up unscheduled column
  $('.schedule-column[data-date=""]').sortable({
    connectWith: ".schedule-column",
    receive: function() {
      applyContestCategoryFilter()
      submitColumn($(this))
    },
  })

  // Set up columns that have dates
  $('.schedule-column[data-date!=""]').sortable({
    connectWith: ".schedule-column",
    update: function() {
      submitColumn($(this))
    },
  })

  // Let users pick a start time for a date column
  $('.start-time-select').change(function() {
    const date = $(this).attr("data-target-date")
    submitColumn($(`.schedule-column[data-date=${date}]`))
  })

  // Make spacers resizable
  $(".spacer").resizable(resizeConfig)

  // Let users add spacers to a schedule column
  $(".add-spacer-button").click(function(e) {
    e.preventDefault();
    const targetDate = $(e.target).attr("data-target-date")
    createSpacer().appendTo(`[data-date=${targetDate}]`)
  })

  // Let users remove spacers, even those that don't exist yet
  $(document).on("click", ".remove-spacer-button", function() {
    const item = $(this).parent()
    const column = $(item).parent(".schedule-column")
    item.remove()
    submitColumn(column)
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

  function submitColumn(column) {
    const data = $(column).getColumnData()
    if (isEmpty(data)) return

    const { csrfToken, submitPath } = options

    $.ajax(submitPath, {
      method: "PATCH",
      beforeSend: function(xhr) {
        xhr.setRequestHeader("X-CSRF-Token", csrfToken)
      },
      data: {
        performances: data,
      },
    }).done(function(result) {
      $.each(result, function(id, { stageTime }) {
        const timeString = stageTime ? toTimeString(stageTime) : null
        $(column).children(`[data-id=${id}]`).find("span#stage-time").html(timeString)
      })
    })
  }

  function createSpacer() {
    const spacerHeight = pixelsFromMinutes(15)
    return $(`<div class="schedule-item spacer"><span class="text-muted"></span><button type="button" class="remove-spacer-button close"><span>&times;</span></button></div>`)
      .css("height", spacerHeight)
      .setMinutesFromHeight(spacerHeight)
      .resizable(resizeConfig)
  }

  $.fn.extend({
    // Updates a spacer's minutes with the given height.
    setMinutesFromHeight: function(height) {
      const minutes = minutesFromPixels(height)
      return $(this)
      .attr("data-minutes", minutes)
      .children("span")
      .html(`${options.dictionary.intermission} (${minutes} min)`)
      .parent()
    },
    // Exports a column to a data structure suitable for submission.
    getColumnData: function() {
      const date = $(this).attr("data-date")
      const items = $.makeArray($(this).children(".schedule-item"))
      const { data } = items.reduce((acc, item) => {
        // Add performance to data object
        const id = $(item).attr("data-id")
        if (id) {
          acc["data"][id] = {
            stageId: date ? options.stageId : null,
            stageTime: date ? calculateStageTime(date, acc.minutes) : null,
          }
        }

        // Update accumulated minutes for next performance
        const itemMinutes = $(item).attr("data-minutes")
        acc.minutes = acc.minutes + parseInt(itemMinutes)
        return acc
      }, { minutes: 0, data: {} })
      return data
    },
    // Creates a map connecting performance ids to stage times.
    toSchedulerMap: function() {
      return $.makeArray($(this)).reduce((acc, item) => {
        acc[item.id] = item
        return acc
      }, {})
    },
  })

  function calculateStageTime(date, minutes) {
    const startTime = $(`.start-time-select[data-target-date=${date}]`).val()
    // Return naive (= no offset) datetime to denote wall time
    return DateTime.fromISO(date + "T" + startTime, "UTC")
      .plus({minutes: minutes})
      .toISO({ includeOffset: false, suppressMilliseconds: true })
  }

  function pixelsFromMinutes(minutes) {
    return minutes * options.pixelsPerMinute
  }

  function minutesFromPixels(pixels) {
    return pixels / options.pixelsPerMinute
  }

  function toTimeString(naiveDateTime) {
    // Assume local time zone here, which should not affect result anyway
    return DateTime.fromISO(naiveDateTime).toFormat("HH:mm")
  }
}

// Make scheduler() available to global <script> tags
window.scheduler = scheduler
