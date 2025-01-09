require Rails.root.join('config/environments/deployed.rb')

Rails.application.configure do
  # Setting host so that url helpers can be used in mailer views.
  config.action_mailer.default_url_options = { host: 'https://findingaids.library.columbia.edu'}

  #set default host for sitemap generator
  config.default_host = "https://findingaids.library.columbia.edu"
end
