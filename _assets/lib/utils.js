import {Url} from '@wendig/lib'

const delay = (fn, millies) => {
  let timeout = null;

  return (...args) => {
    if (timeout) {
      timeout = clearTimeout(timeout)
    }

    // console.log(fn, millies, ...args)
    timeout = setTimeout(fn, millies, ...args)
  }
}

const togglingCollapses = (root) => {
  const collapses = root.querySelectorAll('.collapse')
  for (const c of collapses) {
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

const params = (keys) => {
  let result = {}
  const url = Url.current()
  for (const p of keys) {
    const v = url.hashParams()[p]
    if (v) {
      result[p] = decodeURIComponent(v)
    }
  }
  return result
}

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

const regEscape = (str) => {
  return str.toString().
    replaceAll(/\./g, "\\.").
    replaceAll(/\$/g, "\\$").
    replaceAll(/\^/g, "\\^").
    replaceAll(/\(/g, "\\(").
    replaceAll(/\)/g, "\\)")
}

export {
  delay,
  fold,
  params,
  regEscape,
  togglingCollapses
}