class Item {
  constructor(record) {
    this.d = record
  }

  title() {
    return this.d['Titel/Incipit']
  }

  hasImage() {
    const url = this.imageUrl()
    return !url.match('/dummy.png')
  }

  imageUrl() {
    let upstreamUrls = []

    const bu = this.d['Bild-URL']
    if (bu) {
      upstreamUrls = upstreamUrls.concat(bu.split("\n"))
    }
    let index = upstreamUrls.length

    const bbu = this.d['Bearbeitetes Bild URL']
    if (bbu) {
      upstreamUrls = upstreamUrls.concat(bbu.split("\n"))
    }

    const hashes = this.d['W-Image'] || []

    if (upstreamUrls.length && upstreamUrls.length == hashes.length) {
      if (index >= hashes.length) {index = 0}
      const hash = hashes[index].split(/[\.\/]/)[3]
      return `/assets/images/thumbs/${hash}.jpg`
    } else {
      return '/assets/images/dummy.png'
    }
  }

  upstreamUrl() {
    const wisskiUrl = document.querySelector('meta[name="wisski-url"]').getAttribute('content')
    return `${wisskiUrl}/wisski/navigate/${this.d['id']}/view`
  }

  upstreamEditUrl() {
    const wisskiUrl = document.querySelector('meta[name="wisski-url"]').getAttribute('content')
    return `${wisskiUrl}/wisski/navigate/${this.d['id']}/edit`
  }
}

class Search {
  constructor() {
    this.worker = new Worker('/assets/database.js', {credentials: 'same-origin'});
    this.worker.onmessage = event => {
      if (event.data.action == 'search-results') {
        const items = event.data.results.map(r => new Item(r))
        for (const l of this.listeners) {
          l(items)
        }
      }
    }

    this.listeners = []
  }

  query(criteria) {
    this.worker.postMessage({action: 'search', criteria: criteria})
  }

  addListener(f) {
    this.listeners.push(f)
  }
}

export {
  Item,
  Search
}