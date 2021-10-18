import riot from 'rollup-plugin-riot'
import { nodeResolve } from '@rollup/plugin-node-resolve'
import sass from 'rollup-plugin-sass'

import rollupWatchDir from './_assets/lib/rollup_watch_dir'

export default [
  {
    input: '_assets/app.js',
    output: {
      name: 'app',
      file: 'assets/app.js',
      format: 'iife'
    },
    watch: {
      include: '_assets/**'
    },
    plugins: [
      rollupWatchDir(['_assets/scss/**/*.scss']),
      nodeResolve(),
      riot(),
      sass({
        output: 'assets/app.css',
        watch: 'assets/scss',
        options: {
          sourceMap: true,
          outputStyle: 'expanded'
        },
      })
    ]
  }
]
