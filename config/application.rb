require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LdpdFindingaidsAsi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    #
    # TODO: See if we can autoload lib so that explicit `require` statements aren't
    # necessary for referencing /lib directory files.  Right now, autoloading the
    # lib directory works locally, but causes an issue in GitHub actions when the
    # tests run.  We get this error: `uninitialized constant TrajectPlus`
    config.eager_load_paths << Rails.root.join('lib')

    # https://edgeguides.rubyonrails.org/engines.html#overriding-models-and-controllers
    overrides = "#{Rails.root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)

    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
        load override
      end
    end
    Arclight::Engine.config.catalog_controller_group_query_params['group.limit'] = 3
  end
end
