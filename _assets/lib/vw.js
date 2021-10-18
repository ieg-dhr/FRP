function setVw() {
  let vw = document.documentElement.clientWidth / 100;
  document.documentElement.style.setProperty('--vw', `${vw}px`);
}

function setup() {
  setVw();
  window.addEventListener('resize', setVw);
}

export {
  setup
}
