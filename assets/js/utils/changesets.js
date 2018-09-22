import { defaults, isArray, map, mapValues } from 'lodash'

/**
 * Merges an Ecto changeset's `changes` and `data` values into a
 * single values object, preferring `changes` (changed values) over
 * `data` (original values) if present. This is done recursively
 * for nested changesets as well.
 *
 * @param {Object} changeset
 */
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
