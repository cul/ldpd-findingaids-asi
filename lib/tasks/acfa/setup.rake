# frozen_string_literal: true

#require 'solr_wrapper'
require 'acfa/setup'

namespace :acfa do
  namespace :setup do
    task :all do
      Rake::Task["acfa:setup:config_files"].invoke
      Rake::Task["acfa:setup:ead_fixtures"].invoke
    end

    task :config_files do
      Acfa::Setup.configuration(Rails.root)
    end

    task :ead_fixtures do
      Acfa::Setup.ead_fixtures(Rails.root)
    end
  end
end
