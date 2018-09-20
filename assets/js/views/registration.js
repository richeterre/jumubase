import Vue from 'vue/dist/vue.js'

function signupForm(data) {
  new Vue({
    el: '#signup-form',
    data
  })
}

// Make signupForm() available to global <script> tags
window.signupForm = signupForm

