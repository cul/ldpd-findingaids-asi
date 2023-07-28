# README

## Developer Documentation
### Template Configurations
Template configuration files for local development or testing are available
in `config/templates`. These files are copied into the `config` directory by
`spec/spec_helper.rb`, but the resulting YAML files are git-ignored and should
not be committed to the repository.

### Solr
A generic arclight Solr configuration is provided in `solr/conf`. This
configuration can be loaded into a local Solr instance for development or
testing by running the command `docker-compose up`. The docker configuration
will create a core called "acfa".

### Setting Up A Development Finding Aids Server
1. Install dependencies with `bundle install`. The application Gemfile indicates the required Ruby version.
2. Run the database migrations against sqlite in development with `bundle exec rake db:migrate`
3. Run the rspec suite with `bundle exec rspec` - this will set up the default template configurations
4. Run `bundle exec rake acfa:server` - this will bring up solr, seed it with example data, and start rails
