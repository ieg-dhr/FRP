import {util} from '@wendig/lib'

let queue = []
let storage = {}
let ready = false
let people = []

const types = ['objekt', 'ereignis']
const promises = types.map(type => {
  return fetch(`/data/${type}.json`).
    then(response => response.json()).
    then(data => {
      storage[type] = data
      console.log(`loaded ${type}`)
    })
})
Promise.all(promises).then(data => {
  console.log('ALL loaded')

  aggregate()

  ready = true
  for (const job of queue) {
    handler(job)
  }
  queue = []
})

const aggregate = () => {
  let set = new Set()
  for (const record of storage.objekt) {
    const hn = record['Herstellername']
    record['people'] = hn ? hn.split("\n") : []
    for (const person of record['people']) {
      if (person) {
        set.add(person)
      }
    }
  }
  people = [...set.values()].sort()
}

const handler = event => {
  if (!ready) {
    queue.push(event)
    return
  }

  const messageId = event.data.messageId
  const now = new Date()
  // console.log(event.data)

  if (event.data.action == 'search') {
    let results = storage.objekt
    const criteria = event.data.criteria || {}

    results = results.filter(r => {
      if (criteria.id) {
        if (r['id'] != criteria.id) {return false}
      }

      if (criteria.category) {
        if (r['Objekt in Ausstellung'] != 'Virtuelle Ausstellung') {return false}

        let categories = r['Präsentationsgruppe']
        if (!categories) {return false}

        categories = categories.split("\n")
        const m = categories.includes(criteria.category)
        if (!m) {return false}
      }

      if (criteria.person) {
        const m = r['people'].every(p => p != criteria.person)
        if (m) {return false}
      }

      if (criteria.kind) {
        const m = (r['Objektart'] == criteria.kind)
        if (!m) {return false}
      }

      if (criteria.signature) {
        const term = criteria.signature
        const value = r['Inventarnummer/Signatur'] || ''
        const regex = new RegExp(util.regEscape(`${util.fold(term)}`), 'i')
        const m = util.fold(value).match(regex)
        if (!m) {return false}
      }

      if (criteria.title) {
        const value = util.fold(r['Titel/Incipit'])
        const terms = criteria.title.split(/\s/)
        const m = terms.every(t => {
          const regex = new RegExp(util.regEscape(`${util.fold(t)}`), 'i')
          return value.match(regex)
        })
        if (!m) {return false}
      }

      return true
    })

    results = results.sort((x, y) => {
      const xt = (x['Titel/Incipit'] || '').trim()
      const yt = (y['Titel/Incipit'] || '').trim()
      if (xt == yt) return 0
      return xt < yt ? -1 : 1 
    })

    postMessage({
      messageId: messageId,
      action: 'search-results',
      results: results,
      total: storage.objekt.length
    })

    console.log(`search results generated in ${new Date() - now} ms`)
    return
  }

  if (event.data.action == 'people') {
    postMessage({
      messageId: messageId,
      action: 'people',
      results: people
    })

    console.log(`people list generated in ${new Date() - now} ms`)
    return
  }

  if (event.data.action == 'aggregate') {
    const field = event.data.field

    let set = new Set()
    for (const record of storage.objekt) {
      set.add(record[field])
    }

    postMessage({
      messageId: messageId,
      action: 'aggregation-result',
      results: [...set.values()].sort()
    })

    console.log(`aggregation on '${field}' generated in ${new Date() - now} ms`)
    return
  }

  if (event.data.action == 'lookup') {
    const type = event.data.type
    const id = event.data.id

    let result = null
    for (const record of storage[type]) {
      if (record.id == id) {
        result = record
        break
      }
    }

    if (result) {
      postMessage({
        messageId: messageId,
        action: 'lookup-result',
        result: result,
        type: type
      })
    } else {
      postMessage({
        messageId: messageId,
        action: 'lookup-result',
        result: null,
        type: type
      })
    }

    console.log(`looked up '${type}' '${id}' in ${new Date() - now} ms`)
    return
  }

  if (event.data.action == 'ready') {
    postMessage({
      messageId: messageId,
      action: 'ready'
    })

    console.log(`answering ready state took ${new Date() - now} ms`)
    return
  }

  postMessage({action: 'unknown-action', payload: event.data})
}

onmessage = handler
