import Vue from 'vue/dist/vue.js'

function registrationForm(data) {
  new Vue({
    el: '#registration-form',
    data
  })
}

// Make registrationForm() available to global <script> tags
window.registrationForm = registrationForm
