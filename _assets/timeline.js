import { Timeline } from '@knight-lab/timelinejs'

let instance = null

fetch('/data/timeline.data.json').then(response => response.json()).then(data => {
  const element = document.querySelector('#timeline')
  console.log(element)
  instance = new Timeline('timeline', data, {
    default_bg_color: '#efefef',
    hash_bookmark: true
  })
  instance.zoomIn()
  instance.zoomOut()
})
