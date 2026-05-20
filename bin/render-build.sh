#!/usr/bin/env bash
# Build script for Render.com — runs on every deploy.
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate

# Seed demo data only when the database is empty (first deploy).
bundle exec rails runner "Rails.application.eager_load!; load(Rails.root.join('db','seeds.rb')) if User.count.zero?"
