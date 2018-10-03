import { isEmpty, range } from 'lodash'
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
    'begins_expanded'
  ],

  data() {
    const { appearance: { participant } } = this
    const birthdate = participant.birthdate
    const parsedBirthdate = birthdate && new Date(birthdate)

    return {
      birthdateDay: parsedBirthdate ? String(parsedBirthdate.getDate()) : '',
      birthdateMonth: parsedBirthdate ? String(parsedBirthdate.getMonth() + 1) : '',
      birthdateYear: parsedBirthdate ? String(parsedBirthdate.getFullYear()) : ''
    }
  },

  created() {
    const { appearance } = this
    appearance.role = appearance.role || ''
    appearance.instrument = appearance.instrument || ''
  },

  computed: {
    beginsExpanded() {
      return this.begins_expanded
    },
    panelTitle() {
      const { participant } = this.appearance
      return participant.given_name || "Participant " + (this.index + 1)
    },
    panelClass() {
      const hasErrors = !isEmpty(this.errors)
      return {
        'panel-danger': hasErrors,
        'panel-default': !hasErrors,
      }
    },
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
