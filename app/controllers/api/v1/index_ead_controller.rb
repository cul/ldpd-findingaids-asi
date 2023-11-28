# frozen_string_literal: true

module Api
  module V1
    class IndexEadController < ApiController
      before_action :ensure_json_request

      def index_ead(bibids)
        solr_url = ENV.fetch('SOLR_URL', Blacklight.default_index.connection.base_uri)
        CONFIG[:ead_cache_dir]
        indexed = 0
        bibids.each do |bibid|
          filename = "as_ead_#{bibid}.xml"
          indexing_job = IndexEadJob.new
          indexed += indexing_job.perform(filename)
        end
        if indexed.positive?
          puts "curl #{solr_url}suggest?suggest.build=true"
          `curl #{solr_url}suggest?suggest.build=true`
        else
          puts "no files indexed at #{glob_pattern}"
        end
      end
    end
  end
end
