# SiteBuild
# docker build -t stageirites/sitebuild .
# docker run --rm -v ${PWD}/site/:/home/app/site/ stageirites/sitebuild

# Need to use Ruby 2.6 with Jekyll 4.0 to avoid lots of warning. With Jekyll 4.1, Ruby 2.7 will be OK.
FROM ruby:2.6-alpine

ARG  JEKYLL_VER=4.0

RUN  apk add --no-cache build-base gcc cmake nodejs nodejs-npm git \
&&   gem install jekyll:$JEKYLL_VER jekyll-sitemap:1.4.0 jekyll-paginate:1.1.0 jekyll-seo-tag:2.6.1 jekyll-minifier:0.1.10 contentful_bootstrap jekyll-contentful-data-import \
&&   apk del --purge build-base gcc cmake \
&&   gem cleanup \
&&   rm -rf /usr/lib/ruby/gems/*/cache/* \
&&   rm -rf /var/cache/apk/* /tmp/*

COPY docker_build.sh /bin/docker_build.sh
COPY docker_serve.sh /bin/docker_serve.sh
RUN  chmod 777 /bin/docker_serve.sh \
&&   chmod 777 /bin/docker_build.sh

ENV  JEKYLL_ENV=production

WORKDIR /home/app/

# https://phoenixnap.com/kb/docker-cmd-vs-entrypoint
CMD  docker_build.sh
