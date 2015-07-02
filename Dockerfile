FROM octohost/ruby-1.8.7p352

RUN apt-get update && apt-get install -yy libarchive-dev

COPY . /app
# copy examples file
COPY config/database.yml.example /app/config/database.yml
COPY config/gmaps_api_key.yml.example /app/config/gmaps_api_key.yml

WORKDIR /app
RUN	gem install bundler
RUN bundle install --deployment

RUN bundle exec rake db:migrate && bundle exec rake db:seed

EXPOSE 3000

CMD bundle exec rake daemons:start && RAILS_ENV=development bundle exec script/server
