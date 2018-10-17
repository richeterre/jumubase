import { chain, cloneDeep, defaults, isArray, isObject, map, mapValues } from 'lodash'

/**
 * Merges an Ecto changeset's `changes` and `data` values into a
 * single values object, preferring `changes` (changed values) over
 * `data` (original values) if present. This is done recursively
 * for nested changesets as well.
 *
 * @param {Object} changeset
 */
export function flattenChangesetValues(changeset, params = undefined) {
  const flattenedParams = flattenParams(params || {})
  const result = defaults(
    {},
    changeset.changes,
    flattenedParams,
    changeset.data
  )

  return mapValues(result, (value, key) => {
    if (isChangeset(value)) {
      const subParams = flattenedParams[key]
      return flattenChangesetValues(value, subParams)
    }

    if (isArray(value)) {
      return map(value, (item, index) => {
        const subParams = flattenedParams[key] || []

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

function flattenParams(params) {
  if (isObject(params) && params['0']) {
    // It's an array represented as an object
    // with the keys '0', '1', etc.
    return chain(params)
      .keys()
      .sort()
      .map(k => flattenParams(params[k]))
      .value()
  } else if (isObject(params)) {
    return mapValues(params, flattenParams)
  } else {
    return params
  }
}
