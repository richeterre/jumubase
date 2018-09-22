import Vue from 'vue/dist/vue.js'

import './registration/appearance_fields'
import { flattenChangesetValues } from '../utils/changesets'

const registrationForm = params => new Vue({
  el: '#registration-form',

  data() {
    const {
      changeset,
      contest_category_options,
      birthdate_year_options,
      birthdate_month_options,
      participant_role_options,
      instrument_options
    } = params

    const {
      contest_category_id,
      appearances
    } = flattenChangesetValues(changeset)

    return {
      contest_category_id,
      appearances,
      contest_category_options,
      birthdate_year_options,
      birthdate_month_options,
      participant_role_options,
      instrument_options
    }
  },

  created() {
    this.contest_category_id = this.contest_category_id || ''
  },

  methods: {
    addAppearance() {
      this.appearances.push({
        participant: {}
      })
    }
  }
})

// Make registrationForm() available to global <script> tags
window.registrationForm = registrationForm
