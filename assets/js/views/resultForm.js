import $ from 'jquery'
import "bootstrap-sass"

$('#modal-result-form').on('show.bs.modal', function(event) {
  const $button = $(event.relatedTarget)
  const participantNames = $button.data('participant-names')
  const appearanceIds = $button.data('appearance-ids')
  const currentPoints = $button.data('current-points')

  const $modal = $(this)
  $modal.find('#participant-names').text(participantNames)
  $modal.find('#appearance-ids').val(appearanceIds)
  $modal.find('#results_points').val(currentPoints)
})

$('#modal-result-form').on('shown.bs.modal', function() {
  $(this).find('#results_points').focus()
})
