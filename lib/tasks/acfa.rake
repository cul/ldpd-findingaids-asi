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
    processor_threads = ENV.fetch('THREADS', 1).to_i
    solr_url = ENV.fetch('SOLR_URL', Blacklight.default_index.connection.base_uri)
    puts "Seeding index for #{rails_env}"
    ead_dir = CONFIG[:ead_cache_dir]
    bib_pattern = /ldpd_(\d+).xml$/
    traject_config = Rails.root.join('lib/ead/traject/ead2_config.rb')
    indexer_args = {
      'solr.url' => solr_url.to_s,
      'processing_thread_pool' => processor_threads,
      'writer_class' => 'SolrJsonWriter',
      'solr_writer.commit_on_close' => true
    }
    traject_indexer = Traject::Indexer::NokogiriIndexer.new indexer_args
    traject_indexer.logger.level = 2 # warn
    traject_indexer.load_config_file(traject_config)
    puts "Seeding index with as_ead data from #{ead_dir}..."
    bib = ENV['BIB'] || '*'
    bib = ENV['BIB'] ? "ldpd_#{ENV['BIB']}" : '*'
    filename_pattern = (ENV['CLIO_STUBS'].to_s =~ /true/i) ? "/clio_ead_ldpd_#{bib}.xml" : "/as_ead_#{bib}.xml"
    indexed = 0
    Dir.glob(File.join(ead_dir + filename_pattern)).each do |path|
      bib_id = bib_pattern.match(path)&.[](1)
      # arclight indexes each EAD via a system call to Traject with each ead file path $FILE:
      # `bundle exec traject -u #{solr_url} -i xml -c #{Arclight::Engine.root}/lib/arclight/traject/ead2_config.rb #{ENV.fetch('FILE', nil)}`
      # the traject config (ead2_config.rb) expects an ENV variable set for REPOSITORY_ID
      open(path) do |io|
        traject_indexer.settings['command_line.filename'] = path
        Arclight::Traject::NokogiriNamespacelessReader.new(io, {}).to_a.each do |record|
          context = Traject::Indexer::Context.new(source_record: record, settings: traject_indexer.settings, source_record_id_proc: traject_indexer.source_record_id_proc, logger: traject_indexer.logger)
          traject_indexer.map_to_context!(context)
          unless context.skip?
            traject_indexer.writer.put( context )
            traject_indexer.writer.commit(softCommit: true)
            indexed += 1
          end
        end
      rescue Exception => ex
        puts "#{bib_id} failed to index: #{ex.message}"
      end
    end
    traject_indexer.complete
    if indexed > 0
      puts "curl #{solr_url}suggest?suggest.build=true"
      `curl #{solr_url}suggest?suggest.build=true`
    end
  end
end