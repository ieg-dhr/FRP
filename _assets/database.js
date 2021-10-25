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

const fold = (str) => {
  return str.toString().
    replaceAll(/[äáàâå]/g, 'a').
    replaceAll(/[öóòôðø]/g, 'o').
    replaceAll(/[iíìî]/g, 'i').
    replaceAll(/[ëéèê]/g, 'e').
    replaceAll(/[üúùû]/g, 'u').
    replaceAll(/[ÿ]/g, 'y').
    replaceAll(/æ/g, 'ae').
    replaceAll(/ß/g, 'ss')
}

const handler = event => {
  if (!ready) {
    queue.push(event)
    return
  }

  const now = new Date()
  console.log(event.data)

  if (event.data.action == 'search') {
    let results = storage.objects
    const criteria = event.data.criteria || {}

    results = results.filter(r => {
      if (criteria.title) {
        const value = fold(r['Titel/Incipit'])
        const terms = criteria.title.split(/\s/)
        const m = terms.every(t => {
          const regex = new RegExp(`${fold(t)}`, 'i')
          return value.match(regex)
        })
        if (!m) {return false}
      }

      if (criteria.category) {
        let categories = r['Präsentationsgruppe']
        if (!categories) {return false}

        categories = categories.split("\n")
        const m = categories.includes(criteria.category)
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
      action: 'search-results',
      results: results,
      total: storage.objects.length
    })

    console.log(`search results generated in ${new Date() - now} ms`)
    return
  }

  postMessage({action: 'unknown-action', payload: event.data})
}

onmessage = handler
