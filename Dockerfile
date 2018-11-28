FROM ruby:2.5.1-alpine3.7
WORKDIR /app
COPY Gemfile* ./
RUN bundle config --global frozen 1 \
 && bundle install -j4 --retry 3 --without development test
COPY . .
ENV RACK_ENV production

CMD ["rackup", "-Ilib"]
