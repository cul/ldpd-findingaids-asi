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

    # NOTE: In Rails 7.1, it might be possible to replace the lines below with:
    # config.autoload_lib(ignore: %w(assets tasks ead))
    # See: https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#config-autoload-lib-ignore
    config.eager_load_paths << Rails.root.join('lib')
    Rails.autoloaders.main.ignore(
      # Ignore this directory because Zeitwerk doesn't like autoloading files that do not contain classes or modules
      Rails.root.join('lib', 'ead'),
      # No need to autoload lib/assets directory.
      Rails.root.join('lib', 'assets'),
      # No need to autoload lib/tasks directory.
      Rails.root.join('lib', 'tasks'),
    )

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
