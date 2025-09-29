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
    verbose = ENV.fetch('VERBOSE', 'false') == 'true'
    ead_dir = CONFIG[:ead_cache_dir]
    puts "Seeding index for #{rails_env}"
    bib = ENV['BIB'] ? "cul-#{ENV['BIB']}" : '*'
    filename_pattern = ENV['PATTERN']
    filename_pattern ||= (ENV['CLIO_STUBS'].to_s =~ /true/i) ? "clio_ead_cul-#{bib}.xml" : "as_ead_#{bib}.xml"

    total_indexed = 0
    total_skipped = 0
    all_skip_messages = []

    glob_pattern = File.join(ead_dir, filename_pattern)
    puts "Seeding index with as_ead data from #{glob_pattern}..."

    Dir.glob(glob_pattern).each do |path|
      filename = File.basename(path)
      indexing_job = IndexEadJob.new
      indexing_result = indexing_job.perform(filename)

      total_indexed += indexing_result[:indexed]
      total_skipped += indexing_result[:errors]

      if indexing_result[:skip_messages]&.any?
        all_skip_messages.concat(indexing_result[:skip_messages])
        if verbose
          puts "#{filename} - Skip reasons: #{indexing_result[:skip_messages].join(', ')}"
        end
      end

      puts "Processed #{filename}: indexed #{indexing_result[:indexed]}, skipped #{indexing_result[:errors]}" if verbose
    end

    # Summary report
    puts "\n=== INDEXING SUMMARY ==="
    puts "Files processed: #{total_indexed + total_skipped}"
    puts "Records indexed: #{total_indexed}"
    puts "Records skipped: #{total_skipped}"

    if all_skip_messages.any?
      puts "\nSkip reasons encountered:"
      all_skip_messages.uniq.each { |msg| puts "  - #{msg}" }
    end

    if total_indexed > 0
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
