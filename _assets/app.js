import './app.scss'

// import feather from 'feather-icons'
import * as riot from 'riot'
import * as bootstrap from 'bootstrap'

import App from './components/app.riot'
import Bibliography from './components/bibliography.riot'
import ToTop from './components/to_top.riot'

import {setup as scrollSpySetup} from './lib/scroll_spy'
import {setup as vwSetup} from './lib/vw'

scrollSpySetup()
vwSetup()

riot.register('app', App)
riot.register('bibliography', Bibliography)
riot.register('to-top', ToTop)

riot.mount('app, bibliography, to-top')

// feather.replace()
