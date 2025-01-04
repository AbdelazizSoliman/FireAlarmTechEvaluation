#!/usr/bin/env bash
# exit on error
set -o errexit

# Ensure esbuild binary is executable
chmod +x ./node_modules/.bin/esbuild || echo "esbuild binary not found or already executable"

# Install Ruby gems
bundle install

# Install Node.js dependencies
yarn install --check-files || npm install

# Compile assets
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Perform database migrations (optional, uncomment if needed)
# bundle exec rails db:migrate
