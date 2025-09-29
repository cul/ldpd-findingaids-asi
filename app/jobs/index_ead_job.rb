class IndexEadJob < ApplicationJob
  
  def perform(filename)
    # arclight indexes each EAD via a system call to Traject with each ead file path $FILE:
    # `bundle exec traject -u #{solr_url} -i xml -c #{Arclight::Engine.root}/lib/arclight/traject/ead2_config.rb #{ENV.fetch('FILE', nil)}`
    # the traject config (ead2_config.rb) expects an ENV variable set for REPOSITORY_ID
    processor_threads = ENV.fetch('THREADS', 1).to_i
    solr_url = ENV.fetch('SOLR_URL', Blacklight.default_index.connection.base_uri)
    ead_dir = CONFIG[:ead_cache_dir]
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
    filepath = File.join(ead_dir, filename)
    indexed = 0
    skipped = 0
    skip_messages = []

    begin
      open(filepath) do |io|
        traject_indexer.settings['command_line.filename'] = filepath
        Arclight::Traject::NokogiriNamespacelessReader.new(io, {}).to_a.each do |record|
          context = Traject::Indexer::Context.new(source_record: record, settings: traject_indexer.settings, source_record_id_proc: traject_indexer.source_record_id_proc, logger: traject_indexer.logger)
          traject_indexer.map_to_context!(context)

          if context.skip?
            skip_reason = context.skipmessage || "Unknown reason"
            skip_messages << skip_reason
            puts "Skipping indexing for #{filename}: #{skip_reason}"
            skipped += 1
            next
          end
      
          traject_indexer.writer.put( context )
          traject_indexer.writer.commit(softCommit: true)
          indexed += 1
        end
      end
    rescue Exception => ex
      puts "#{filename} failed to index: #{ex.message}"
      skipped += 1
    end
    
    traject_indexer.complete
    puts "Indexed #{indexed} records, skipped #{skipped} records"
    
    { indexed: indexed, errors: skipped }
  end
  
end
