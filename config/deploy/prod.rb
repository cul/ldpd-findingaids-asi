server 'acfa-rails-prod1.cul.columbia.edu', user: fetch(:remote_user), roles: %w(app db web)
# Current branch is suggested by default in development
# fcd1, 03/31/20: Change deploy default from current branch (I believe) to latest tag
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
ask :branch, proc { `git tag --sort=version:refname`.split("\n").last }
