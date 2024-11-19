# frozen_string_literal: true

require 'acfa/index'

module Api
  module V1
    class IndexController < ApiController
      before_action :authenticate_request_token

      def index_ead
        bibids = params[:bibids]
        solr_url = ENV.fetch('SOLR_URL', Blacklight.default_index.connection.base_uri)
        indexed = 0
        bibids.each do |bibid|
          filename = "as_ead_#{bibid}.xml"
          indexing_job = IndexEadJob.new
          indexed += indexing_job.perform(filename)
        end
        if indexed.positive?
          Acfa::Index.build_suggester(solr_url)
        else
          Rails.logger.debug "no files indexed for bibids: #{bibids.join(', ')}"
        end
        render plain: "Success!"
      end

      def delete_ead
        bibids = params[:bibids]
        solr_url = ENV.fetch('SOLR_URL', Blacklight.default_index.connection.base_uri)
        deleted = 0
        bibids.each do |bibid|
          delete_job = DeleteEadJob.new
          deleted += delete_job.perform(bibid)
        end
        if deleted.positive?
          Acfa::Index.build_suggester(solr_url)
        else
          Rails.logger.debug "no bibids deleted"
        end
        render plain: "Success!"
      end

    end
  end
end
