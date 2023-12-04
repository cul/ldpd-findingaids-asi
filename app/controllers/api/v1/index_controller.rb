# frozen_string_literal: true

require 'acfa/index'

module Api
  module V1
    class IndexController < ApiController
      before_action :authenticate_request_token

      def index_ead
        bibids = params[:bibids]
        solr_url = ENV.fetch('SOLR_URL', Blacklight.default_index.connection.base_uri)
        CONFIG[:ead_cache_dir]
        indexed = 0
        bibids.each do |bibid|
          filename = "as_ead_#{bibid}.xml"
          indexing_job = IndexEadJob.new
          indexed += indexing_job.perform(filename)
        end
        if indexed.positive?
          Acfa::Index.build_suggester(solr_url)
        else
          puts "no files indexed at #{glob_pattern}"
        end
        render plain: "Success!"
      end
    end
  end
end
