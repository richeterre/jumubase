import $ from 'jquery'
import "bootstrap-sass"

$('#modalResultForm').on('show.bs.modal', function(event) {
  const $button = $(event.relatedTarget)
  const participantName = $button.data('participant-name')
  const appearanceId = $button.data('appearance-id')
  const currentPoints = $button.data('current-points')

  const $modal = $(this)
  $modal.find('#participant-name').text(participantName)
  $modal.find('#appearance-id').val(appearanceId)
  $modal.find('#points-input').val(currentPoints)
})

$('#modalResultForm').on('shown.bs.modal', function() {
  $(this).find('#points-input').focus()
})
