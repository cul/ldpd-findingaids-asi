module Api
  module V1
    class AdminController < ApiController
      before_action :authenticate_request_token_or_user

      # POST /api/v1/admin/refresh_resource
      def refresh_resource
        resource_uri = refresh_resource_params[:resource_record_uri]
        include_unpublished = refresh_resource_params[:include_unpublished] == 'true'

        client = Acfa::ArchivesSpace::Client.new(
          base_uri: ARCHIVESSPACE[:base_uri],
          username: ARCHIVESSPACE[:username],
          password: ARCHIVESSPACE[:password],
        )

        bib_id = client.bib_id_for_resource(resource_uri: resource_uri)
        ead_filename = "as_ead_cul-#{bib_id}.xml"
        client.download_ead(resource_uri: resource_uri, filename: ead_filename, include_unpublished: include_unpublished)
        IndexEadJob.perform_now(ead_filename) # The IndexEadJob expects only a filename, not a full path

        render json: {result: true, resource_id: "cul-#{bib_id}"}
      rescue Net::ReadTimeout
        render json: {result: false, error: 'ArchivesSpace EAD download took too long and the request timed out.'}
      rescue Acfa::Exceptions::InvalidArchivesSpaceResourceUri, Acfa::Exceptions::InvalidEadXml => e
        render json: {result: false, error: e.message}
      end

      private

      def refresh_resource_params
        params.permit([:resource_record_uri, :include_unpublished])
      end
    end
  end
end
