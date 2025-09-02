# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

# Load rails environment
require File.expand_path('../config/environment', __dir__)

# Set environment to current environment.
set :environment, Rails.env

# Our job template wraps the cron job in a script that emails out any errors.
# This is a CUL provided script. More details can be found here:
# https://wiki.library.columbia.edu/display/USGSERVICES/Cron+Management
# Errors will be emailed out to email specified in secrets.yml.
set :email_subject, 'Cron'
set :error_recipient, Rails.application.credentials.cron_errors
set :job_template, "/usr/local/bin/mailifrc -s 'Error - :email_subject' :error_recipient -- /bin/bash -l -c ':job'"

# Overriding to remove output redirection option.
job_type :rake, 'cd :path && :environment_variable=:environment bundle exec rake :task'

# Regenerate sitemap every .
if Rails.env.findingaids_prod?
  every :wednesday, at: '4am' do
    rake 'sitemap:create', email_subject: 'Sitemap generation'
  end
end