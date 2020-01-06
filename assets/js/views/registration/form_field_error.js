import Vue from 'vue/dist/vue'

Vue.component('form-field-error', {
  props: ['errors'],

  template: `
    <div v-if="errors" class="has-error">
      <small v-for="error in errors" class="help-block">
        {{error}}
      </small>
    </div>
  `,
})
