import { range, rangeRight } from 'lodash'
import Vue from 'vue/dist/vue.js'

Vue.component('appearance-fields', {
  props: [
    'appearance',
    'index',
    'birthdate_year_options',
    'birthdate_month_options',
    'participant_role_options',
    'instrument_options'
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
  },

  computed: {
    daysInBirthdateMonth() {
      return range(1, 32)
    }
  },

  methods: {
    fieldId(...attributes) {
      const suffix = attributes.join('_')
      return `performance_appearances_${this.index}_${suffix}`
    },

    fieldName(...attributes) {
      const suffix = attributes.map(a => `[${a}]`).join('')
      return `performance[appearances][${this.index}]${suffix}`
    },

    formatDay(day) {
      return day < 10 ? `0${day}` : String(day)
    },
  }
})
