# SiteBuild
# docker build -t stageirites/sitebuild .
# docker run --rm -v ${PWD}/site/:/home/app/site/ stageirites/sitebuild

# Need to use Ruby 2.6 with Jekyll 4.0 to avoid lots of warning. With Jekyll 4.1, Ruby 2.7 will be OK.
FROM ruby:2.6-alpine

ARG  JEKYLL_VER=4.0

RUN  apk add --no-cache build-base gcc cmake nodejs nodejs-npm git \
&&   gem install jekyll:$JEKYLL_VER jekyll-sitemap:1.4.0 jekyll-paginate-v2:3.0.0 jekyll-seo-tag:2.6.1 jekyll-minifier:0.1.10 \
&&   apk del --purge build-base gcc cmake \
&&   gem cleanup \
&&   rm -rf /usr/lib/ruby/gems/*/cache/* \
&&   rm -rf /var/cache/apk/* /tmp/*

COPY build.sh  /bin/build.sh
RUN  chmod 777 /bin/build.sh

ENV  JEKYLL_ENV=production

WORKDIR /home/app/

# https://phoenixnap.com/kb/docker-cmd-vs-entrypoint
ENTRYPOINT ["/bin/build.sh"]

