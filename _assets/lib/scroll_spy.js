import {delay} from './utils'

const debounce = (fn) => {
  let frame
  return (...params) => {
    if (frame) { 
      cancelAnimationFrame(frame)
    }
    frame = requestAnimationFrame(() => {
      fn(...params)
    })
  } 
}

const storeScroll = () => {
  const data = document.documentElement.dataset
  data.scrollY = window.scrollY

  const docHeight = document.body.scrollHeight
  const footerHeight =
    document.querySelector('footer').offsetHeight - 
    document.querySelector('footer > div:nth-child(1)').offsetHeight
  const viewportHeight = document.documentElement.clientHeight

  // console.log(window.scrollY, docHeight, footerHeight)

  if (window.scrollY <= 300) {
    data.scrollRange = 'none'
    return
  }

  if (window.scrollY >= docHeight - viewportHeight - footerHeight) {
    data.scrollRange = 'over'
    return
  }

  data.scrollRange = 'some'
}

export function setup() {
  document.addEventListener('scroll', delay(storeScroll, 0), {passive: true});
  storeScroll()
}
