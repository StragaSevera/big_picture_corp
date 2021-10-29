# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'down', '~> 5.0'
gem 'thwait'

group :development do
  gem 'pry'
  gem 'rubocop'
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'rspec'
  gem 'vcr'
  gem 'webmock'
end
