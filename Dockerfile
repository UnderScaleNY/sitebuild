# SiteBuild
# docker build -t stageirites/sitebuild .

# Need to use Ruby 2.6 with Jekyll 4.0 to avoid lots of warning. With Jekyll 4.1, Ruby 2.7 will be OK.
FROM ruby:2.6-alpine

WORKDIR /home/app/
COPY build.sh  /bin/build.sh
COPY Gemfile   /home/app/Gemfile

RUN  apk add --no-cache build-base gcc cmake nodejs nodejs-npm \
&&   bundle install \
&&   apk del --purge build-base gcc cmake \
&&   rm -rf /usr/lib/ruby/gems/*/cache/* \
&&   rm -rf /var/cache/apk/* /tmp/* \
&&   chmod 777 /bin/build.sh

ENV  JEKYLL_ENV=production

# https://phoenixnap.com/kb/docker-cmd-vs-entrypoint
ENTRYPOINT ["/bin/build.sh"]

