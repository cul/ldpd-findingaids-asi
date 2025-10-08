# frozen_string_literal: true

require 'acfa/index'

module Api
  module V1
    class IndexController < ApiController
      before_action :authenticate_request_token

      def index_ead
        bibids = params[:bibids]
        solr_url = ENV.fetch('SOLR_URL', Blacklight.default_index.connection.base_uri)

        success_count = 0
        failure_count = 0
        error_messages = []

        bibids.each do |bibid|
          filename = "as_ead_#{bibid}.xml"
          indexing_job = IndexEadJob.new
          result = indexing_job.perform(filename)

          success_count += result[:indexed]
          failure_count += result[:errors]

          if result[:skip_messages]&.any?
            error_messages.concat(result[:skip_messages])
          end
        end

        if success_count.positive?
          Acfa::Index.build_suggester(solr_url)
        else
          Rails.logger.debug "no files indexed for bibids: #{bibids.join(', ')}"
        end

        render json: {
          success: success_count,
          failure: failure_count,
          errorMessages: error_messages.uniq
        }
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
