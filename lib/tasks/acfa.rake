# frozen_string_literal: true

#require 'solr_wrapper'
require 'acfa/setup'

namespace :acfa do
  desc 'Setup templated configurations as necessary'
  task :setup_config do
    Acfa::Setup.configuration(File.expand_path('../..', __dir__))
  end

  desc 'Run Solr and Application for interactive development'
  task :server, %i[rails_server_args] do |_t, args|
    print 'Starting Solr...'
    SolrWrapper.wrap do |solr|
      puts 'done.'
      solr.with_collection do
        Rake::Task['acfa:seed'].invoke
        system "bundle exec rails s #{args[:rails_server_args]}"
      end
    end
  end

  desc 'Seed fixture data to Solr'
  task seed: [:setup_config, :environment] do
    rails_env = (ENV['RAILS_ENV'] || 'development')
    solr_url = ENV.fetch('SOLR_URL', Blacklight.default_index.connection.base_uri)
    ead_dir = CONFIG[:ead_cache_dir]
    puts "Seeding index for #{rails_env}"
    bib_pattern = /cul-(\d+).xml$/
    bib = ENV['BIB'] ? "cul-#{ENV['BIB']}" : '*'
    filename_pattern = ENV['PATTERN']
    filename_pattern ||= (ENV['CLIO_STUBS'].to_s =~ /true/i) ? "clio_ead_cul-#{bib}.xml" : "as_ead_#{bib}.xml"
    indexed = 0
    glob_pattern = File.join(ead_dir, filename_pattern)
    puts "Seeding index with as_ead data from #{glob_pattern}..."
    Dir.glob(glob_pattern).each do |path|
      filename = File.basename(path)
      indexing_job = IndexEadJob.new
      indexed += indexing_job.perform(filename)
    end
    if indexed > 0
      puts "curl #{solr_url}suggest?suggest.build=true"
      `curl #{solr_url}suggest?suggest.build=true`
    else
      puts "no files indexed at #{glob_pattern}"
    end
  end

  desc 'Delete finding aid from index by collection id'
  task delete_collection: [:setup_config, :environment] do
    rails_env = (ENV['RAILS_ENV'] || 'development')
    solr_con = Blacklight.default_index.connection
    solr_response = solr_con.delete_by_query "_root_:#{ENV['COLLECTION']}"
    solr_con.commit(softCommit: true)
    solr_url = solr_con.base_uri
    `curl #{solr_url}suggest?suggest.build=true`
    puts solr_response.inspect
  end
end
