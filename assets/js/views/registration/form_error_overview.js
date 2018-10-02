import { isEmpty } from 'lodash'
import Vue from 'vue/dist/vue'

Vue.component('form-error-overview', {
  props: ['errors'],

  computed: {
    hasErrors: function() {
      return !isEmpty(this.errors)
    }
  },

  template: `
    <div v-if="hasErrors" class="alert alert-danger">
      <p>Please fix the errors below and try again!</p>
      <p v-if="errors.base">
        <ul>
          <li v-for="error in errors.base">{{error}}</li>
        </ul>
      </p>
    </div>
  `
})
