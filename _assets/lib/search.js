class Item {
  constructor(record) {
    this.d = record
  }

  id() {
    return this.d['id']
  }

  title() {
    return this.d['Titel/Incipit']
  }

  verwalter() {
    let results = []
    let name = null

    name = this.d['Verwalter (Name)']
    if (name) {
      results.push({name: name})
    }

    name = this.d['Verwalter (Ort)']
    if (name) {
      results.push({name: name})
    }

    return results
  }

  herstellung() {
    let results = {}

    const roles = this.d['Herstellerrolle']
    if (roles) {
      const roleList = roles.split("\n")
      const names = this.d['Herstellername'].split("\n")

      for (let i = 0; i < roleList.length; i++) {
        const r = roleList[i]
        const n = names[i]
        if (!r || !n) {continue}

        results[r] = results[r] || []
        results[r].push({name: n})
      }
    }

    return results
  }

  technique() {
    const v = this.d['Technik']

    if (v) {
      return v.split("\n").map(e => {
        return {
          name: e
        }
      })
    }
  }

  hasImage() {
    return !!this.d['images'].length
  }

  // hasImage() {
  //   const url = this.imageUrl()
  //   return !url.match('/dummy.png')
  // }

  urlForImageData(data, resolution = 'thumbs') {
    return `/data/images/${resolution}/${data.hash}.jpg`
  }

  exhibitImageUrl(resolution = 'thumbs') {
    let data = null

    if (this.d['W-Image-First-Is-Primary']) {
      data = this.d['images'][0]

      return data ? this.urlForImageData(data, resolution) : undefined
    }

    data = this.d['cropped'][0] || this.d['images'][0]
    return data ? this.urlForImageData(data, resolution) : undefined
  }

  imageUrls(resolution = 'thumbs') {
    return this.d['images'].map(data => this.urlForImageData(data, resolution))
  }

  // imageUrl() {
  //   if (this.d['W-Image-First-Is-Primary']) {
  //     const comps = this.d['W-Image'][0].split(/[\/\.]/)
  //     const hash = comps[comps.length - 2]
  //     return `/assets/images/thumbs/${hash}.jpg`
  //   }

  //   let upstreamUrls = []

  //   const bu = this.d['Bild-URL']
  //   if (bu) {
  //     upstreamUrls = upstreamUrls.concat(bu.split("\n"))
  //   }
  //   let index = upstreamUrls.length

  //   const bbu = this.d['Bearbeitetes Bild URL']
  //   if (bbu) {
  //     upstreamUrls = upstreamUrls.concat(bbu.split("\n"))
  //   }

  //   const hashes = this.d['W-Image'] || []

  //   if (upstreamUrls.length && upstreamUrls.length == hashes.length) {
  //     if (index >= hashes.length) {index = 0}
  //     const hash = hashes[index].split(/[\.\/]/)[3]
  //     return `/assets/images/thumbs/${hash}.jpg`
  //   } else {
  //     return '/assets/images/dummy.png'
  //   }
  // }

  upstreamUrl() {
    const wisskiUrl = document.querySelector('meta[name="wisski-url"]').getAttribute('content')
    return `${wisskiUrl}/wisski/navigate/${this.d['id']}/view`
  }

  upstreamEditUrl() {
    const wisskiUrl = document.querySelector('meta[name="wisski-url"]').getAttribute('content')
    return `${wisskiUrl}/wisski/navigate/${this.d['id']}/edit`
  }

  exhibitUrl() {
    return `/exhibit#?id=${this.id()}`
  }

  objectUrl() {
    return `/object#?id=${this.id()}`
  }
}

class Search {
  constructor() {
    this.worker = new Worker('/assets/database.js', {credentials: 'same-origin'});
    this.worker.onmessage = event => {
      if (event.data.action == 'search-results') {
        const items = event.data.results.map(r => new Item(r))
        const total = event.data.total
        for (const l of this.listeners) {
          l(items, total)
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
