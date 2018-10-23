import { find, findIndex, isEmpty, isString } from 'lodash'
import Vue from 'vue/dist/vue.js'

import './registration/appearance_panel'
import './registration/form_error_summary'
import './registration/form_field_error'
import './registration/piece_panel'
import { flattenChangesetValues } from '../utils/changesets'
import { toDateObject } from '../utils/date'

const registrationForm = options => new Vue({
  el: '#registration-form',

  data() {
    const {
      changeset,
      params,
      contest_category_options,
      birthdate_year_options,
      birthdate_month_options,
      role_options,
      instrument_options,
      epoch_options,
      vocabulary,
    } = options

    const {
      contest_category_id,
      appearances,
      pieces,
    } = flattenChangesetValues(changeset, params)

    const errors = isEmpty(changeset.errors) ? {} : changeset.errors

    return {
      contest_category_id: contest_category_id || '',
      appearances: (appearances || []).map(normalizeAppearance),
      pieces: (pieces || []).map(normalizePiece),
      contest_category_options,
      birthdate_year_options,
      birthdate_month_options,
      role_options,
      instrument_options,
      epoch_options,
      vocabulary,
      errors,
      expandedAppearancePanelIndex: getExpandedAppearancePanelIndex(errors),
      expandedPiecePanelIndex: getExpandedPiecePanelIndex(errors),
    }
  },

  computed: {
    genre() {
      const {
        contest_category_id: cc_id,
        contest_category_options: cc_options,
      } = this

      const cc = lookupContestCategoryOption(cc_options, cc_id)
      return cc && cc.genre
    },
  },

  methods: {
    contestCategoryChanged() {
      const {
        appearances,
        contest_category_id: cc_id,
        contest_category_options: cc_options,
        pieces,
      } = this

      const cc = lookupContestCategoryOption(cc_options, cc_id)

      if (isEmpty(appearances)) {
        switch (cc.type) {
          case "solo":
            this.appearances = [
              normalizeAppearance({role: 'soloist'}),
              normalizeAppearance({role: 'accompanist'}),
            ]
            break
          case "ensemble":
            this.appearances = [
              normalizeAppearance({role: 'ensemblist'}),
              normalizeAppearance({role: 'ensemblist'}),
            ]
            break
          case "solo_or_ensemble":
            this.appearances = [normalizeAppearance({})]
            break
        }
      }

      if (isEmpty(pieces)) {
        switch (cc.genre) {
          case "classical":
          case "kimu":
            this.pieces = [normalizePiece({})]
            break
          case "popular":
            this.pieces = [normalizePiece({epoch: "e"})]
            break
        }
      }
    },
    addAppearance() {
      this.appearances.push(normalizeAppearance({}))
    },
    removeAppearance(index) {
      const { appearances, errors } = this
      appearances.splice(index, 1)
      errors.appearances && errors.appearances.splice(index, 1)
    },
    addPiece() {
      this.pieces.push(normalizePiece({}))
    },
    removePiece(index) {
      const { pieces, errors } = this
      pieces.splice(index, 1)
      errors.pieces && errors.pieces.splice(index, 1)
    },
  },
})

// Determines which appearance panel should initially be expanded.
function getExpandedAppearancePanelIndex(errors) {
  if (errors.appearances) {
    return findIndex(errors.appearances, e => !isEmpty(e))
  } else {
    return null
  }
}

// Determines which piece panel should initially be expanded.
function getExpandedPiecePanelIndex(errors) {
  if (errors.pieces) {
    return findIndex(errors.pieces, e => !isEmpty(e))
  } else {
    return null
  }
}

// Initalizes the appearance's field values, if not present.
function normalizeAppearance(appearance) {
  return {
    ...appearance,
    participant: normalizeParticipant(appearance.participant || {}),
    role: appearance.role || '',
    instrument: appearance.instrument || '',
  }
}

// Initalizes the participant's field values, if not present.
function normalizeParticipant(participant) {
  const { day, month, year } = getBirthdateObject(participant.birthdate)

  return {
    ...participant,
    given_name: participant.given_name || '',
    family_name: participant.family_name || '',
    birthdate_day: day || '',
    birthdate_month: month || '',
    birthdate_year: year || '',
  }
}

// Initalizes the piece's field values, if not present.
function normalizePiece(piece) {
  return {
    ...piece,
    title: piece.title || '',
    composer: piece.composer || '',
    artist: piece.artist || '',
    epoch: piece.epoch || '',
  }
}

function lookupContestCategoryOption(cc_options, cc_id) {
  return find(cc_options, o => o.id === cc_id)
}

function getBirthdateObject(birthdate) {
  return isString(birthdate) ? toDateObject(birthdate) : {}
}

// Make registrationForm() available to global <script> tags
window.registrationForm = registrationForm
