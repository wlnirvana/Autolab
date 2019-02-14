FROM alpine:3.9
MAINTAINER fzeng@andrew.cmu.edu

RUN apk update && apk --update add ruby ruby-irb ruby-json ruby-rake \
    ruby-bigdecimal ruby-io-console libstdc++ tzdata postgresql-client nodejs

ADD Gemfile /app/
ADD Gemfile.lock /app/

# Move the database configuration into place
ADD config/database.docker.yml /app/webapp/config/database.yml

RUN apk --update add --virtual build-dependencies build-base ruby-dev openssl-dev \
    postgresql-dev libc-dev linux-headers && \
    gem install bundler && \
    cd /app ; bundle install --without development test && \
    apk del build-dependencies

ADD . /app
RUN chown -R nobody:nogroup /app
USER nobody

ENV RAILS_ENV production
WORKDIR /app

CMD ["bundle", "exec", "unicorn", "-p", "8080", "-c", "./config/unicorn.rb"]
