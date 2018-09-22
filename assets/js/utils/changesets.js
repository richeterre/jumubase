import { defaults, isArray, map, mapValues } from 'lodash'

export function flattenChangesetValues(changeset) {
  const result = defaults({}, changeset.changes, changeset.data)

  return mapValues(result, value => {
    if (isChangeset(value)) {
      return flattenChangesetValues(value)
    }

    if (isArray(value)) {
      return map(value, item => {
        return isChangeset(item) ? flattenChangesetValues(item) : item
      })
    }

    return value
  })
}

function isChangeset(object) {
  return !!object && !!object.data && !!object.changes
}
