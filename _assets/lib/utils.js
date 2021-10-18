const delay = (fn, millies) => {
  let timeout = null;

  return (...args) => {
    if (timeout) {
      timeout = clearTimeout(timeout)
    }

    timeout = setTimeout(fn, millies, ...args)
  }
}

export {
  delay
}