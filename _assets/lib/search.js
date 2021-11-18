import Item from './item'
import EventItem from './event_item'

let messageId = 10000
let instanceRegistry = []

const worker = new Worker('/assets/database.js', {credentials: 'same-origin'})
worker.onmessage = event => {
  const data = event.data
  const action = data.action

  if (action == 'search-results') {
    const items = data.results.map(r => new Item(r))
    data.results = items
  }

  if (action == 'lookup-result') {
    const klass = {
      'objekt': Item,
      'ereignis': EventItem
    }[data.type]
    data.result = new klass(data.result)
  }

  for (const instance of instanceRegistry) {
    instance.onResponse(event)
  }
}

export default class Search {
  constructor() {
    instanceRegistry.push(this)

    this.listeners = {}
    this.resolveMap = {}
  }

  onResponse(event) {
    const data = event.data
    const action = data.action
    const listeners = this.listeners[action] || []

    for (const l of listeners) {
      l(data)
    }

    const resolve = this.resolveMap[data.messageId]
    if (resolve) {
      resolve(data)
      delete this.resolveMap[data.messageId]
    }
  }

  query(criteria) {
    return this.postMessage({action: 'search', criteria: criteria})
  }

  people() {
    return this.postMessage({action: 'people'})
  }

  aggregate(field) {
    return this.postMessage({action: 'aggregate', field: field})
  }

  lookup(type, id) {
    return this.postMessage({action: 'lookup', type: type, id: id})
  }

  ready() {
    return this.postMessage({action: 'ready'})
  }

  postMessage(data) {
    const newId = messageId
    messageId += 1

    const promise = new Promise((resolve, reject) => {
      this.resolveMap[newId] = resolve

      data.messageId = newId
      worker.postMessage(data)
    })

    return promise
  }

  addListener(action, f) {
    this.listeners[action] = this.listeners[action] || []
    this.listeners[action].push(f)
  }
}
