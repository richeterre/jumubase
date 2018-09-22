import { range } from 'lodash'
import Vue from 'vue/dist/vue'

import { formFieldId, formFieldName } from '../../utils/form_fields'


Vue.component('appearance-fields', {
  props: [
    'appearance',
    'index',
    'birthdate_year_options',
    'birthdate_month_options',
    'participant_role_options',
    'instrument_options',
    'errors'
  ],

  data() {
    const { appearance: { participant } } = this
    const birthdate = participant.birthdate
    const parsedBirthdate = birthdate && new Date(birthdate)

    return {
      birthdateDay: parsedBirthdate ? String(parsedBirthdate.getDate()) : '',
      birthdateMonth: parsedBirthdate ? String(parsedBirthdate.getMonth() + 1) : '',
      birthdateYear: parsedBirthdate ? String(parsedBirthdate.getFullYear()) : '',
    }
  },

  created() {
    const { appearance } = this
    appearance.participant_role = appearance.participant_role || ''
    appearance.instrument = appearance.instrument || ''

    this.errors = this.errors || {}
    this.errors.participant = this.errors.participant || {}
  },

  computed: {
    daysInBirthdateMonth() {
      return range(1, 32)
    }
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
      return day < 10 ? `0${day}` : String(day)
    },
  }
})
