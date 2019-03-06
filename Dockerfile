FROM ruby:2.5-alpine

RUN apk add --update --no-cache \
      bash \
      build-base \
      fontconfig \
      ghostscript \
      git \
      gmp-dev \
      msttcorefonts-installer \
      && update-ms-fonts \
      && fc-cache -f

WORKDIR /app
COPY * /app/

RUN bundle install -j 4 --path /vendor/bundle

CMD ["/bin/bash"]
