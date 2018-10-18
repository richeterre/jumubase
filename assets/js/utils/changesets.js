import { chain, cloneDeep, defaults, isArray, isObject, map, mapValues, padStart } from 'lodash'

/**
 * Merges an Ecto changeset's `changes` and `data` values into a
 * single values object, preferring `changes` (changed values) over
 * `data` (original values) if present. This is done recursively
 * for nested changesets as well.
 *
 * @param {Object} changeset
 */
export function flattenChangesetValues(changeset, params = undefined) {
  const normalizedParams = normalizeParams(params || {})
  const result = defaults(
    {},
    changeset.changes,
    normalizedParams,
    changeset.data
  )

  return mapValues(result, (value, key) => {
    if (isChangeset(value)) {
      const subParams = normalizedParams[key]
      return flattenChangesetValues(value, subParams)
    }

    if (isArray(value)) {
      return map(value, (item, index) => {
        const subParams = normalizedParams[key] || []

        return isChangeset(item)
          ? flattenChangesetValues(item, subParams[index])
          : cloneDeep(item)
      })
    }

    return value
  })
}

function isChangeset(object) {
  return !!object && !!object.data && !!object.changes
}

function isDateObject(object) {
  return !!object && !!object.day && !!object.month && !!object.year
}

function normalizeParams(params) {
  if (isObject(params) && params['0']) {
    // It's an array represented as an object
    // with the keys '0', '1', etc.
    return chain(params)
      .keys()
      .sort()
      .map(k => normalizeParams(params[k]))
      .value()
  } else if (isDateObject(params)) {
    return toDateString(params)
  } else if (isObject(params)) {
    return mapValues(params, normalizeParams)
  } else {
    return params
  }
}

function toDateString({ year, month, day }) {
  const paddedMonth = padStart(month, 2, '0')
  const paddedDay = padStart(day, 2, '0')
  return `${year}-${paddedMonth}-${paddedDay}`
}
