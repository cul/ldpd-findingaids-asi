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
    start_at = ENV['START_AT']

    ead_dir = CONFIG[:ead_cache_dir]
    puts "Seeding index for #{rails_env}"
    bib = ENV['BIB'] ? "cul-#{ENV['BIB']}" : '*'
    filename_pattern = ENV['PATTERN']
    filename_pattern ||= (ENV['CLIO_STUBS'].to_s =~ /true/i) ? "clio_ead_cul-#{bib}.xml" : "as_ead_#{bib}.xml"
    indexed = 0
    glob_pattern = File.join(ead_dir, filename_pattern)
    puts "Seeding index with as_ead data from #{glob_pattern}..."
    file_paths = Dir.glob(glob_pattern).sort

    # If a start_at argument has been supplied, skip all files before the specified filename.
    # This is useful if you indexing job is interrupted and you want to continue where you left off.
    # Generally you need to run the indexing process with VERBOSE=true to know what has been processed so far.
    if start_at
      index_of_start_value = file_paths.find_index { |el| el.end_with?(start_at) } || 0
    else
      index_of_start_value = 0
    end

    file_paths.each_with_index do |path, i|
      next if i < index_of_start_value

      filename = File.basename(path)
      indexing_job = IndexEadJob.new
      indexed += indexing_job.perform(filename)
      puts "Processed #{filename} (#{i+1} of #{file_paths.length})" if verbose
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

  namespace :embedding_cache do
    desc "Export embedding_cache to JSONL (usage: rake acfa:embedding_cache:export JSONL_PATH=/path/to/file.jsonl)"
    task export: :environment do
      path = ENV["JSONL_PATH"]
      unless path
        abort "You must provide JSONL_PATH environmental variable"
      end

      count = 0
      failed = 0

      File.open(path, "w") do |file|
        EmbeddingCache.find_each do |row|
          begin
            file.puts(row.to_json)
            count += 1
            print "\rExported #{count} records..." if count % 100 == 0
          rescue => e
            failed += 1
            Rails.logger.error("Failed to export record ID #{row.doc_id}: #{e.message}")
          end
        end
      end
      puts "Successfully exported #{count} records to #{path}"
      puts "Failed to export #{failed} records (see logs)" if failed > 0
    end

    desc "Import embedding_cache from JSONL (usage: rake acfa:embedding_cache:import JSONL_PATH=/path/to/file.jsonl)"
    task import: :environment do
      path = ENV["JSONL_PATH"]
      unless path
        abort "You must provide JSONL_PATH environmental variable"
      end

      count = 0
      failed = 0

      File.foreach(path) do |line|
        next if line.strip.empty?

        begin
          data = JSON.parse(line)
          EmbeddingCache.upsert(data, unique_by: [:doc_id, :model_identifier, :value_hash])
          count += 1
          print "\rImported #{count} records..." if count % 100 == 0
        rescue => e
          failed += 1
          Rails.logger.error("Error importing doc id #{data["doc_id"]}: #{e.class} - #{e.message}")
        end
      end
      puts "Successfully imported #{count} records to #{path}"
      puts "Failed to import #{failed} records (see logs)" if failed > 0
    end
  end

end
