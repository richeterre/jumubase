import { padStart } from 'lodash'

export function isDateObject(object) {
  return !!object && !!object.day && !!object.month && !!object.year
}

export function toDateObject(dateString) {
  const date = new Date(dateString)

  return {
    day: date.getDate(),
    month: date.getMonth() + 1,
    year: date.getFullYear(),
  }
}

export function toDateString({ year, month, day }) {
  const paddedMonth = padStart(month, 2, '0')
  const paddedDay = padStart(day, 2, '0')
  return `${year}-${paddedMonth}-${paddedDay}`
}
