const delay = (fn, millies) => {
  let timeout = null;

  return (...args) => {
    if (timeout) {
      timeout = clearTimeout(timeout)
    }

    timeout = setTimeout(fn, millies, ...args)
  }
}

const togglingCollapses = (root) => {
  const collapses = root.querySelectorAll('.collapse')
  for (const c of collapses) {
    console.log(c)
    const toggle = c.getAttribute('toggle')
    if (toggle) {
      c.addEventListener('show.bs.collapse', event => {
        document.getElementById(toggle).classList.toggle('invisible')
      })
      c.addEventListener('hidden.bs.collapse', event => {
        document.getElementById(toggle).classList.toggle('invisible')
      })
    }
  }
}

export {
  delay,
  togglingCollapses
}