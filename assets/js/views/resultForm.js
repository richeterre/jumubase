import $ from 'jquery'
import "bootstrap-sass"

$('#modalResultForm').on('show.bs.modal', function(event) {
  const $button = $(event.relatedTarget)
  const participantNames = $button.data('participant-names')
  const appearanceIds = $button.data('appearance-ids')
  const currentPoints = $button.data('current-points')

  const $modal = $(this)
  $modal.find('#participant-names').text(participantNames)
  $modal.find('#appearance-ids').val(appearanceIds)
  $modal.find('#points-input').val(currentPoints)
})

$('#modalResultForm').on('shown.bs.modal', function() {
  $(this).find('#points-input').focus()
})
