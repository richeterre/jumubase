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

  computed: {
    beginsExpanded() {
      return this.begins_expanded
    },
    panelTitle() {
      const { appearance: { participant, role }, index } = this
      return getPanelTitle(participant, role, index)
    },
    panelClass() {
      return isEmpty(this.errors) ? 'panel-default' : 'panel-danger'
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

function getPanelTitle(participant, role, index) {
  const name = getParticipantName(participant, index)
  return role ? `${name} (${role})` : name
}

function getParticipantName(participant, index) {
  const fullName = `${participant.given_name} ${participant.family_name}`
  return fullName.trim() || "Participant " + (index + 1)
}