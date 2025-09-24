#!/usr/bin/env bash
# exit on error
set -o errexit

# Build commands for production
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Run database migrations
bundle exec rails db:migrate

# Seed the database if it's empty
bundle exec rails runner "
  if Question.count == 0
    puts 'Seeding database...'
    load Rails.root.join('db', 'seeds.rb')
    puts 'Database seeded successfully!'
  else
    puts 'Database already has data, skipping seed.'
  end
"
