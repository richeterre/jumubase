import _, { chain, cloneDeep, isArray, isObject, map, mapValues, mergeWith, toArray } from 'lodash'

import { isDateObject, toDateString } from './date'

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
  const result = defaultsDeep(
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

// Similar to Lodash's defaultsDeep, but preserves arrays
// (which is crucial for removing nested associations)
function defaultsDeep() {
  let output = {}
  toArray(arguments).reverse().forEach(item => {
      mergeWith(output, item, (objectValue, sourceValue) => {
          return isArray(sourceValue) ? sourceValue : undefined
      })
  })
  return output
}

function isChangeset(object) {
  return !!object && !!object.data && !!object.changes
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
