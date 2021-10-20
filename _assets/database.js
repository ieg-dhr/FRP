let queue = []
let storage = {}
let ready = false

fetch('/data/objekt.json').
  then(response => response.json()).
  then(data => {
    console.log('loaded', data)
    storage.objects = data
    ready = true

    for (const job of queue) {
      handler(job)
    }
    queue = []
  })

const handler = event => {
  if (!ready) {
    queue.push(event)
    return
  }

  console.log(event.data)

  if (event.data.action == 'search') {
    let results = storage.objects
    const criteria = event.data.criteria || {}

    if (criteria.title) {
      const regex = new RegExp(`${criteria.title}`)
      results = results.filter(r => {
        return (r['Titel/Incipit'] || '').match(regex)
      })
    }

    if (criteria.category) {
      results = results.filter(r => {
        return r['Präsentationsgruppe'] == criteria.category
      })
    }

    postMessage({action: 'search-results', results: results})
    return
  }

  postMessage({action: 'unknown-action', payload: event.data})
}

onmessage = handler
