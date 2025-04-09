module Api
  module V1
    class AdminController < ApiController
      before_action :authenticate_request_token_or_user

      # POST /api/v1/admin/refresh_resource
      def refresh_resource
        resource_uri = refresh_resource_params[:resource_record_uri]
        include_unpublished = refresh_resource_params[:include_unpublished] == 'true'

        repository_id, resource_id = validate_and_parse_resource_uri!(resource_uri)

        client = Acfa::ArchivesSpace::Client(
          base_uri: ARCHIVESSPACE[:base_uri],
          username: ARCHIVESSPACE[:username],
          password: ARCHIVESSPACE[:password],
        )

        download_path = client.download_ead(
          repository_id: repository_id,
          resource_id: resource_id,
          download_directory_path: File.join(CONFIG[:ead_cache_dir], ead_filename)
        )

        IndexEadJob.perform_now(File.basename(download_path)) # The IndexEadJob expects only a filename, not a full path

        render json: {result: true, resource_id: "cul-#{bib_id}"}
      rescue Net::ReadTimeout
        render json: {result: false, error: 'ArchivesSpace EAD download took too long and the request timed out.'}
      rescue Acfa::Exceptions::InvalidArchivesSpaceResourceUri => e
        render json: {result: false, error: e.message}
      end

      private

      def refresh_resource_params
        params.expect([:resource_record_uri, :include_unpublished])
      end

      def validate_and_parse_resource_uri!(resource_uri)
        # Validate and parse params ###############################################
        resource_uri_regexp = /^\/*repositories\/(\d+)\/resources\/(\d+)$/
        matches = resource_uri_regexp.match(resource_uri)


        if matches.nil?
          raise Acfa::Exceptions::InvalidArchivesSpaceResourceUri,
                'Invalid format resource_uri.  Expected a value like: /repositories/2/resources/2024'
        end

        [matches[1], matches[2]] # [repository_id, resource_id]
      end
    end
  end
end
