source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 3.0.3"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0.6'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use sqlite3 as the database for Active Record
# fcd1, 03/29/22: Rails 6 doesn't like '~> 1.3.13'. As ldpd-amesa does, spec to ~> 1.4
gem 'sqlite3', '~> 1.4'
# Use mysql2 as the database for CUL
gem 'mysql2'
# Use Puma as the app server
gem 'puma', '~> 5.2'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# fcd1, 07/09/19: Disabled turbolinks due to performance issues
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'marc'
gem 'iso-639'

# fcd1, 03/29/22: Getting bundle install errors on all-nginx-dev1 for 1.13.3
# As seen in ldpd-amesa Gemfile, spec at 1.10.10
gem 'nokogiri', '~> 1.10.10'
gem 'loofah', '~> 2.19.1'

gem 'arclight', '~> 1.0.0'

gem "rsolr", ">= 1.0", "< 3"
gem "bootstrap", "\~\>\ 5.1"
gem "sassc-rails", "~> 2.1"
gem "devise"
gem "devise-guests", "~> 0.8"
gem "blacklight-locale_picker"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem "capistrano", "~> 3.11", require: false
  gem "capistrano-rails", "~> 1.4", require: false
  gem 'capistrano-rvm', '~> 0.1', require: false
  gem 'capistrano-passenger', '~> 0.2', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Run against the latest stable release
group :development, :test do
  gem 'rspec-rails'
  gem "solr_wrapper", ">= 0.3"
end
gem "blacklight-locale_picker"
