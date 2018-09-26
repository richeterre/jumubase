/**
 * Turns a form field path (e.g.: 'performance', 'appearances', '0', 'role')
 * into a form element ID, using the same algorithm as Phoenix does.
 *
 * @param {...string} path
 */
export function formFieldId(...path) {
  return path.join('_')
}

/**
 * Turns a form field path (e.g.: 'performance', 'appearances', '0', 'role')
 * into a form element name, using the same algorithm as Phoenix does.
 *
 * @param {...string} path
 */
export function formFieldName(...path) {
  const [firstPart, ...otherParts] = path
  return firstPart + otherParts.map(part => `[${part}]`).join('')
}
