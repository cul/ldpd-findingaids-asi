server 'acfa-rails-dev1.cul.columbia.edu', user: 'ldpdserv', roles: %w(app db web)
# Current branch is suggested by default in development
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
