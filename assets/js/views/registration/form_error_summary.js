import { isEmpty } from 'lodash'
import Vue from 'vue/dist/vue'

Vue.component('form-error-summary', {
  props: ['errors'],

  computed: {
    hasErrors: function() {
      return !isEmpty(this.errors)
    }
  }
})
