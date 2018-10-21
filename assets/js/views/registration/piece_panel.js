import { isEmpty } from 'lodash'
import Vue from 'vue/dist/vue'

import { formFieldId, formFieldName } from '../../utils/form_fields'

Vue.component('piece-panel', {
  props: [
    'piece',
    'index',
    'epoch_options',
    'errors',
    'begins_expanded',
    'piece_term',
    'genre',
  ],

  computed: {
    beginsExpanded() {
      return this.begins_expanded
    },
    panelTitle() {
      const { piece, index, piece_term } = this
      return getPanelTitle(piece, piece_term, index)
    },
    panelClass() {
      return isEmpty(this.errors) ? 'panel-default' : 'panel-danger'
    },
    hasComposerFields() {
      return this.genre === "classical"
    },
    hasArtistField() {
      return this.genre === "popular"
    },
  },

  methods: {
    fieldId(...attributes) {
      return formFieldId(
        'performance',
        'pieces',
        this.index,
        ...attributes
      )
    },

    fieldName(...attributes) {
      return formFieldName(
        'performance',
        'pieces',
        this.index,
        ...attributes
      )
    },
  },
})

function getPanelTitle(piece, pieceTerm, index) {
  const { composer, title } = piece
  const displayTitle = title || `${pieceTerm} ${index + 1}`
  return composer ? `${composer}: ${displayTitle}` : displayTitle
}
