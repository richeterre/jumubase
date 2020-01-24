import { includes, isEmpty } from 'lodash'
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
      return getPanelTitle(this)
    },
    panelClass() {
      return isEmpty(this.errors) ? 'panel-default' : 'panel-danger'
    },
    hasComposerFields() {
      return isClassicalOrKimu(this.genre) && !isTraditional(this.piece)
    },
    hasArtistField() {
      return isPopular(this.genre) && !isTraditional(this.piece)
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

function getPanelTitle(props) {
  const { genre, index, piece, piece_term } = props
  const { artist, composer, title } = piece

  const titleText = title.trim() || `${piece_term} ${index + 1}`
  const composerText = composer.trim()
  const artistText = artist.trim()

  if (isTraditional(piece)) {
    return `${titleText} (trad.)`
  } else if (isClassicalOrKimu(genre) && composerText) {
    return `${composerText}: ${titleText}`
  } else if (isPopular(genre) && artistText) {
    return `${titleText} (${artistText})`
  } else {
    return titleText
  }
}

function isClassicalOrKimu(genre) {
  return includes(["classical", "kimu"], genre)
}

function isPopular(genre) {
  return genre === "popular"
}

function isTraditional(piece) {
  return piece.epoch === "trad"
}
