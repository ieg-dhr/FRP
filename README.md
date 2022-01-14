# Friedensbilder Code & Data

This repository contains code, data and more on a separate frontend for the
collaborative project “Dass Gerechtigkeit und Friede sich küssen –
Repräsentationen des Friedens im vormodernen Europa”
(http://www.friedensbilder.net/).


## Data

The data was originally extracted from a [WissKI](https://wiss-ki.eu/) database.
The metadata were downloaded from a CSV api and then enriched with web scraping
and manual edits. Only the original CSV (see `_raw_data/upstream_csv`), the
scraped data (see `_raw_data/upstream_ids`) and the final state (see
`data/*.json`) have been preserved. Should you be interested in the process,
you may inspect the code in the `_plugins` and `_plugins.archive` directories.

The images were downloaded from WissKI as well: They consist of roughly 1200
files (jpg, png, tif and pdf). They are not included here on github because they
require more than 20G of disk size. If you are interested in obtaining them,
please contact Henning Jürgens at the
[Leibniz Institute of European History](https://www.ieg-mainz.de). See below
for how to use these images.


## Deployment

Deployment assumes that the original WissKI application is still available. Note
down its url. Here, we will assume `http://friedensbilder.net`:

This frontend has been created with [jekyll](https://jekyllrb.com/). Therefore,
install ruby (>= 2.7.5) on your workstation. We also added a number of web
components built with webpack. This is why you will also need nodejs (>= 12) to
build the page

With that done, first clone the repository and create a config
file `.env.local` with the WissKI url:

```bass
git clone https://github.com/ieg-dhr/FRP.git
cd FRP
echo 'UPSTREAM_URL="http://friedensbilder.net"' > .env.local
```

Then, obtain the images (see above) package and extract the images into a
directory `_raw_data/images/original`. The archive is compressed with
`zstandard`.

Now, run

```bass
bundle install
npm install
npm run build
bundle exec jekyll build
```

This will take some time when you run it the first time, because the thumbnails
need to be generated. Once the process finishes, the frontend will be available
in the `_site` directory. Copy all files within to a destination of your choice
on your servers.


## Development

The steps are identical to the steps for deployment except the last command is
instead

    bundle exec jekyll serve --livereload

which spawns a webserver at http://127.0.0.1:4000 hosting the page. Changes to
the source code are immediately reflected there.

The code also contains a considerable amount javascript code, bundled with a
webpack configuration. If you would like to make changes to the javascript
components, please run

    npm run dev

The components are then automatically rebuilt when changes to the source code
occur. Simply run this alongside the above jekyll command in a second terminal.
