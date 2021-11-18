export default class EventItem {
  constructor(record) {
    this.d = record
  }

  id() {
    return this.d['id']
  }

  title() {
    return this.d['Ereignis']
  }

  kurztitel() {
    return this.listFrom(this.d['Kurztitel']).map(e => {
      return {
        name: e
      }
    })
  }

  groups() {
    return this.listFrom(this.d['Beteiligte Gruppen']).map(e => {
      return {
        name: e
      }
    })
  }

  countries() {
    return this.listFrom(this.d['Beteiligte Länder']).map(e => {
      return {
        name: e
      }
    })
  }

  people() {
    return this.listFrom(this.d['Beteiligte Person']).map(e => {
      return {
        name: e
      }
    })
  }

  listFrom(value) {
    return value ? value.split("\n") : []
  }
}
