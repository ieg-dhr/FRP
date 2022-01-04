import { Timeline } from '@knight-lab/timelinejs'
import {rootPath} from './lib/utils'

let instance = null

fetch(`${rootPath()}/data/timeline.data.json`).then(response => response.json()).then(data => {
  // prepend root path
  for (const e of data.events) {
    e.text.headline = e.text.headline.replace(/"\/event\?/, `"${rootPath()}/event?`)
  }
  console.log(data)

  const element = document.querySelector('#timeline')
  instance = new Timeline('timeline', data, {
    default_bg_color: '#efefef',
    hash_bookmark: true,
    initial_zoom: 3,
    debug: true
  })

  // const observer = new MutationObserver((list, o) => {
  //   for (const mutation of list) {
  //     console.log(mutation, mutation.target)
  //   }
  // })

  const check = () => {
    window.clearTimeout(to)
    // const config = {attributes: true, attributeFilter: ['style']};
    // observer.observe(e, config);
    // console.log(window.getComputedStyle(e).left)

    const e = element.querySelector('.tl-timenav-slider')
    e.style.left = '50px'
  }
  let to = window.setTimeout(check, 500)

  window.timeline = instance
})
