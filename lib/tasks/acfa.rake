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
    puts "Seeding index for #{rails_env}"
    eads_to_index_yml = ENV.fetch('EAD_YML', CONFIG[:valid_finding_aid_bib_ids])
    ead_hash = HashWithIndifferentAccess.new(YAML.load_file(eads_to_index_yml))
    ead_dir = CONFIG[:ead_cache_dir]
    bib_pattern = /ldpd_(\d+).xml$/
    traject_config = Rails.root.join('lib/ead/traject/ead2_config.rb')
    puts "Seeding index with as_ead data from #{ead_dir}..."
    filename_pattern = (ENV['CLIO_STUBS'].to_s =~ /true/i) ? "/clio_ead_ldpd_*.xml" : "/as_ead_ldpd_*.xml"
    Dir.glob(File.join(ead_dir + filename_pattern)).each do |path|
      bib_id = bib_pattern.match(path)&.[](1)
      repo_id = ead_hash[bib_id.to_i]
      if repo_id && Arclight::Repository.find_by(slug: repo_id)
        # arclight indexes each EAD via a system call to Traject with each ead file path $FILE:
        # `bundle exec traject -u #{solr_url} -i xml -c #{Arclight::Engine.root}/lib/arclight/traject/ead2_config.rb #{ENV.fetch('FILE', nil)}`
        # the traject config (ead2_config.rb) expects an ENV variable set for REPOSITORY_ID
        puts "REPOSITORY_ID=#{repo_id} bundle exec traject -u #{solr_url} -i xml -c #{traject_config} #{path}"
        `REPOSITORY_ID=#{repo_id} bundle exec traject -u #{solr_url} -i xml -c #{traject_config} #{path}`
      else
        if repo_id.present?
          puts "no repository found for #{repo_id}"
        else
          puts "no repository code found for #{bib_id}" unless repo_id.present?
        end
      end
    end
  end
end