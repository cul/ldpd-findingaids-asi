# frozen_string_literal: true

#require 'solr_wrapper'

namespace :acfa do
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
  task seed: :environment do
    rails_env = (ENV['RAILS_ENV'] || 'development')
    solr_url = ENV.fetch('SOLR_URL', Blacklight.default_index.connection.base_uri)
    ead_dir = CONFIG[:ead_cache_dir]
    puts "Seeding index for #{rails_env}"
    bib_pattern = /ldpd_(\d+).xml$/
    bib = ENV['BIB'] ? "ldpd_#{ENV['BIB']}" : '*'
    filename_pattern = ENV['PATTERN']
    filename_pattern ||= (ENV['CLIO_STUBS'].to_s =~ /true/i) ? "clio_ead_ldpd_#{bib}.xml" : "as_ead_#{bib}.xml"
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
  
  desc 'Seed a list of EADs by path to Solr'
  task index_list: :environment do
    rails_env = (ENV['RAILS_ENV'] || 'development')
    solr_url = ENV.fetch('SOLR_URL', Blacklight.default_index.connection.base_uri)
    ead_dir = CONFIG[:ead_cache_dir]
    puts "Indexing into #{rails_env} #{solr_url}"
    indexed = 0
    list_path = ENV['LIST']
    if File.exist?(list_path)
      puts "Indexing ead paths from #{list_path}..."
      open(list_path) do |io|
        io.each do |line|
          path = line.strip
          filename = File.basename(path)
          indexing_job = IndexEadJob.new
          indexed += indexing_job.perform(filename)
        end
      end
    end
    if indexed > 0
      puts "curl #{solr_url}suggest?suggest.build=true"
      `curl #{solr_url}suggest?suggest.build=true`
    else
      puts "no files indexed from #{list_path}"
    end
  end

  desc 'Delete finding aid from index by collection id'
  task delete_collection: :environment do
    rails_env = (ENV['RAILS_ENV'] || 'development')
    solr_con = Blacklight.default_index.connection
    solr_response = solr_con.delete_by_query "_root_:#{ENV['COLLECTION']}"
    solr_con.commit(softCommit: true)
    solr_url = solr_con.base_uri
    `curl #{solr_url}suggest?suggest.build=true`
    puts solr_response.inspect
  end
end