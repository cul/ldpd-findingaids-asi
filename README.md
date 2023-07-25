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
