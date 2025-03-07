require 'yaml'

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

def font_awesome_token
  return ENV['FONT_AWESOME_TOKEN'] if ENV['FONT_AWESOME_TOKEN'] && ENV['FONT_AWESOME_TOKEN'] != ''
  YAML.load(File.read("./config/secrets.yml")).fetch('font_awesome_token', nil) if File.exist?("./config/secrets.yml")
end

ruby "~> 3.1.3"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0.6'

gem 'resque', '~> 2.6'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use sqlite3 as the database for Active Record
# fcd1, 03/29/22: Rails 6 doesn't like '~> 1.3.13'. As ldpd-amesa does, spec to ~> 1.4
gem 'sqlite3', '~> 1.6.7'
# Use mysql2 as the database for CUL
gem 'mysql2'

# Use terser as compressor for JavaScript assets
gem 'terser'

# Use Puma as the app server
gem 'puma', '~> 5.2'

# Use JavaScript with Vite [https://github.com/sergii/vite_rails]
gem 'vite_rails'

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

gem 'nokogiri', '~> 1.15.2'
gem 'loofah', '~> 2.19.1'

gem 'arclight', '~> 1.1.4'
gem 'blacklight', '~> 8.5.0'

gem "font-awesome-sass", "~> 6.4.0"
fa_token = font_awesome_token
if fa_token
  source "https://token:#{fa_token}@dl.fontawesome.com/basic/fontawesome-pro/ruby/" do
    gem "font-awesome-pro-sass", "~> 6.4.0"
  end
else
  raise 'ERROR: You are missing font_awesome_token in secrets.yml.  It is required for `bundle install` to work.'
end
gem "rsolr", ">= 1.0", "< 3"
gem "bootstrap", "\~\>\ 5.1"
gem "sassc-rails", "~> 2.1"
gem "devise", '~> 4.9' # omniauth-cul is only known to be compatible with devise ~> 4.9
gem "omniauth", '~> 2.1' # omniauth-cul is only known to be compatible with omniauth ~> 2.1
gem "omniauth-cul", '~> 0.2.0' # omniauth-cul is only known to be compatible with omniauth ~> 2.1
gem "devise-guests", "~> 0.8"
gem "blacklight-locale_picker"
gem "blacklight_range_limit"
gem "sitemap_generator"
gem 'whenever', require: false

gem 'archivesspace-client'

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
  gem 'capistrano', '~> 3.18.0', require: false
  gem 'capistrano-cul', require: false
  gem 'capistrano-passenger', '~> 0.1', require: false
  gem 'capistrano-rails', '~> 1.4', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Run against the latest stable release
group :development, :test do
  gem 'capybara', '~> 3.32'
  gem 'rspec-rails'
  gem "solr_wrapper", ">= 0.3"
end
