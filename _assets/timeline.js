import { Timeline } from '@knight-lab/timelinejs'

let instance = null

fetch('/data/timeline.data.json').then(response => response.json()).then(data => {
  const element = document.querySelector('#timeline')
  console.log(element)
  instance = new Timeline('timeline', data, {
    default_bg_color: '#efefef',
    hash_bookmark: true
  })

  const to = window.setTimeout(() => {
    if (instance.ready) {
      window.clearTimeout(to)
      // instance.zoomIn()
      // instance.zoomOut()

      console.log()

      // document.querySelector('.tf-storyslider').setAttribute('style', 'min-height: 370px')
    }
  }, 200)
})
