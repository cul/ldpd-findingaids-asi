# README

## Developer Documentation

## Requirements

* MySQL

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

### Setting Up A Vite Server
1. Install `nvm` (Node Version Manager) if you do not already have it with `brew install nvm`
2. Follow the [instructions](https://github.com/nvm-sh/nvm?tab=readme-ov-file#calling-nvm-use-automatically-in-a-directory-with-a-nvmrc-file) from the nvm repo to set up automatic Node version switching
3. Open a new terminal window at the repo — this should automatically switch you to run the `node` version specified by `.nvmrc` and download it if necessary.
4. Install yarn with `npm install --global yarn`
5. Install Javascript dependencies with `yarn install`.
6. Run the vite server `yarn start:dev` - this will handle asset imports for the app.

### Setting Up A Development Finding Aids Server
1. Install Ruby dependencies with `bundle install`. The application Gemfile indicates the required Ruby version.
2. Run the rspec suite with `bundle exec rspec` - this will set up the default template configurations
3. Run the database migrations against sqlite in development with `bundle exec rake db:migrate`
4. For running Solr, you have two options:
   1. **Option 1:** Run `docker compose up` to start the solr server and then run `bundle exec rake acfa:seed` to seed the solr server with sample data.
   2. **Option 2:** Run `bundle exec rake acfa:server` to start up solr, seed it with example data, and start rails.
