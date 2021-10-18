import fg from 'fast-glob'
import path from 'path'

const factory = (globs) => {
  return {
    transform() {
      for (const item of globs) {
        const files = fg.sync(path.resolve(item))
        for (const filename of files) {
          this.addWatchFile(filename)
        }
      }
    }
  }
}

export default factory
