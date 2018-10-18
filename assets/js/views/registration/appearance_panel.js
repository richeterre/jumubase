import { isEmpty, padStart, range } from 'lodash'
import Vue from 'vue/dist/vue'

import { formFieldId, formFieldName } from '../../utils/form_fields'


Vue.component('appearance-panel', {
  props: [
    'appearance',
    'index',
    'birthdate_year_options',
    'birthdate_month_options',
    'role_options',
    'instrument_options',
    'errors',
    'begins_expanded',
    'participant_term',
    'role_terms',
  ],

  computed: {
    beginsExpanded() {
      return this.begins_expanded
    },
    panelTitle() {
      const {
        appearance: { participant, role },
        index,
        participant_term,
        role_terms,
      } = this

      const name = getParticipantName(participant, participant_term, index)
      return role ? `${name} (${role_terms[role]})` : name
    },
    panelClass() {
      return isEmpty(this.errors) ? 'panel-default' : 'panel-danger'
    },
    daysInBirthdateMonth() {
      return range(1, 32)
    },
  },

  methods: {
    fieldId(...attributes) {
      return formFieldId(
        'performance',
        'appearances',
        this.index,
        ...attributes
      )
    },

    fieldName(...attributes) {
      return formFieldName(
        'performance',
        'appearances',
        this.index,
        ...attributes
      )
    },

    formatDay(day) {
      return padStart(String(day), 2, '0')
    },
  },
})

function getParticipantName(participant, participantTerm, index) {
  const fullName = `${participant.given_name} ${participant.family_name}`
  const fallback = `${participantTerm} ${index + 1}`
  return fullName.trim() || fallback
}
