module Api
  module V1
    class AdminController < ApiController
      before_action :authenticate_request_token_or_user

      # POST /api/v1/admin/refresh_resource
      def refresh_resource
        resource_record_uri = refresh_resource_params[:resource_record_uri]
        include_unpublished = refresh_resource_params[:include_unpublished].to_s == 'true'

        bib_id = Acfa::ArchivesSpace::Client.instance.bib_id_for_resource(resource_record_uri: resource_record_uri)
        ead_filename = bib_id_to_filename(bib_id)
        Acfa::ArchivesSpace::Client.instance.download_ead(
          resource_record_uri: resource_record_uri, filename: ead_filename, include_unpublished: include_unpublished
        )
        IndexEadJob.perform_now(ead_filename) # The IndexEadJob expects only a filename, not a full path

        render json: {result: true, resource_id: "cul-#{bib_id}"}
      rescue Net::ReadTimeout
        render json: {result: false, error: 'ArchivesSpace EAD download took too long and the request timed out.'}, status: :internal_server_error
      rescue Acfa::Exceptions::InvalidArchivesSpaceResourceUri => e
        render json: {result: false, error: e.message}, status: :bad_request
      rescue Acfa::Exceptions::InvalidEadXml, Acfa::Exceptions::UnexpectedArchivesSpaceApiResponse => e
        render json: {result: false, error: e.message}, status: :internal_server_error
      rescue ArchivesSpace::ConnectionError
        render json: {result: false, error: 'Unable to connect to ArchivesSpace.'}, status: :internal_server_error
      end

      # Download the EAD cache zip file (generated monthly by a cron job)
      def download_ead_cache
        zip_file_path = CONFIG[:ead_cache_zip_path]
        return render json: { result: false, error: 'No cached EAD zip files found.' }, status: :not_found unless File.exist?(zip_file_path)

        send_file(zip_file_path, filename: File.basename(zip_file_path))
      end

      private

      def bib_id_to_filename(bib_id)
        "as_ead_cul-#{bib_id}.xml"
      end

      def refresh_resource_params
        params.permit([:resource_record_uri, :include_unpublished])
      end
    end
  end
end
