import './app.scss'

import * as riot from 'riot'
// import * as bootstrap from 'bootstrap'

import App from './components/app.riot'
import Bibliography from './components/bibliography.riot'
import DbObject from './components/db_object.riot'
import Exhibit from './components/exhibit.riot'
import ExhibitionGrid from './components/exhibition_grid.riot'
import SearchForm from './components/search_form.riot'
import SearchResults from './components/search_results.riot'
import ToTop from './components/to_top.riot'

import {setup as scrollSpySetup} from './lib/scroll_spy'
import {setup as vwSetup} from './lib/vw'

scrollSpySetup()
vwSetup()

riot.register('app', App)
riot.register('bibliography', Bibliography)
riot.register('db-object', DbObject)
riot.register('exhibition-grid', ExhibitionGrid)
riot.register('exhibit', Exhibit)
riot.register('search-form', SearchForm)
riot.register('search-results', SearchResults)
riot.register('to-top', ToTop)

riot.mount('app, bibliography, db-object, exhibit, exhibition-grid, search-form, search-results, to-top')

document.addEventListener('readystatechange', event => {
  if (document.readyState == 'complete') {
    document.body.removeAttribute('style')
  }
})
