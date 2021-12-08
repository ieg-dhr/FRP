export default class Item {
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

  verwalterAlt() {
    let results = []
    let name = null

    name = this.d['Verwalter (Name) dupl.']
    if (name) {
      results.push({name: name})
    }

    name = this.d['Verwalter (Ort) dupl.']
    if (name) {
      results.push({name: name})
    }

    return results
  }

  herstellung() {
    let results = {}

    const roles = this.d['Herstellerrolle']
    const names = this.d['Herstellername']

    if (roles && names) {
      const roleList = roles.split("\n")
      const nameList = names.split("\n")

      for (let i = 0; i < roleList.length; i++) {
        const r = roleList[i]
        const n = nameList[i]
        if (!r || !n) {continue}

        results[r] = results[r] || []
        results[r].push({name: n})
      }
    }

    return results
  }

  technique() {
    return this.listFrom(this.d['Technik']).map(e => {
      return {
        name: e
      }
    })
  }

  signatur() {
    const types = this.listFrom(this.d['Signatur (Typ)'])
    const contents = this.listFrom(this.d['Signatur (Inhalt)'])
    const positions = this.listFrom(this.d['Signatur (Position)'])

    let results = []
    for (const [i, t] of Object.entries(types)) {
      const c = contents[i]
      const p = positions[i]

      results.push({name: `${t}, ${p}: „${c}“`})
    }
    
    return results
  }

  kurztitel() {
    return this.listFrom(this.d['Kurztitel']).map(e => {
      return {
        name: e
      }
    })
  }

  seitenzahl() {
    return this.listFrom(this.d['Seitenzahl']).map(e => {
      return {
        name: e
      }
    })
  }

  listFrom(value) {
    return value ? value.split("\n") : []
  }

  hasImage() {
    return !!this.d['images'].length
  }

  // hasImage() {
  //   const url = this.imageUrl()
  //   return !url.match('/dummy.png')
  // }

  urlForImageData(data, resolution = 'thumbs') {
    return `/data/images/${resolution}/${data.hash}.png`
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

  upstreamUrl() {
    const wisskiUrl = document.querySelector('meta[name="wisski-url"]').getAttribute('content')
    return `${wisskiUrl}/wisski/navigate/${this.d['id']}/view`
  }

  upstreamEditUrl() {
    const wisskiUrl = document.querySelector('meta[name="wisski-url"]').getAttribute('content')
    return `${wisskiUrl}/wisski/navigate/${this.d['id']}/edit`
  }

  exhibitUrl() {
    return `/exhibit?id=${this.id()}`
  }

  objectUrl() {
    return `/object?id=${this.id()}`
  }
}
