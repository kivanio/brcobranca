FROM ruby:2.5-alpine
RUN apk add --update --no-cache build-base bash git ghostscript

WORKDIR /app
COPY * /app/

RUN bundle install -j 4 --path /vendor/bundle

CMD ["/bin/bash"]
