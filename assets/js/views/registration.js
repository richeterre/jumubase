import { findIndex, isEmpty } from 'lodash'
import Vue from 'vue/dist/vue.js'

import './registration/appearance_panel'
import './registration/form_error_summary'
import './registration/form_field_error'
import { flattenChangesetValues } from '../utils/changesets'

const registrationForm = params => new Vue({
  el: '#registration-form',

  data() {
    const {
      changeset,
      contest_category_options,
      birthdate_year_options,
      birthdate_month_options,
      role_options,
      instrument_options
    } = params

    const {
      contest_category_id,
      appearances
    } = flattenChangesetValues(changeset)

    const errors = isEmpty(changeset.errors) ? {} : changeset.errors

    return {
      contest_category_id: contest_category_id || '',
      appearances: (appearances || []).map(normalizeAppearance),
      contest_category_options,
      birthdate_year_options,
      birthdate_month_options,
      role_options,
      instrument_options,
      errors,
      expandedAppearancePanelIndex: getExpandedAppearancePanelIndex(errors)
    }
  },

  methods: {
    addAppearance() {
      this.appearances.push(normalizeAppearance({}))
    },
    removeAppearance(index) {
      const { appearances, errors } = this
      appearances.splice(index, 1)
      errors.appearances && errors.appearances.splice(index, 1)
    }
  }
})

// Determines which appearance panel should initially be expanded.
function getExpandedAppearancePanelIndex(errors) {
  if (isEmpty(errors)) {
    return 0
  } else if (errors.appearances) {
    return findIndex(errors.appearances, e => !isEmpty(e))
  } else {
    return null
  }
}

// Initalizes the appearance's field values, if not present.
function normalizeAppearance(appearance) {
  return {
    ...appearance,
    participant: normalizeParticipant(appearance.participant || {}),
    role: appearance.role || '',
    instrument: appearance.instrument || ''
  }
}

// Initalizes the participant's field values, if not present.
function normalizeParticipant(participant) {
  return {
    ...participant,
    given_name: participant.given_name || '',
    family_name: participant.family_name || ''
  }
}

// Make registrationForm() available to global <script> tags
window.registrationForm = registrationForm
