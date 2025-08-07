class Acfa::ArchivesSpace::Client < ArchivesSpace::Client
  RESOURCE_RECORD_URI_REGEXP = /^\/*repositories\/(\d+)\/resources\/(\d+)$/

  def self.instance
    unless @instance
      @instance = self.new(ArchivesSpace::Configuration.new({
        base_uri: ARCHIVESSPACE[:base_uri],
        username: ARCHIVESSPACE[:username],
        password: ARCHIVESSPACE[:password],
        timeout: ARCHIVESSPACE[:timeout]
      }))
      @instance.login # Our Acfa::ArchivesSpace::Client subclass logs in automatically when it is initialized
    end
    @instance
  end

  # We are overriding the ArchivesSpace::Client so that if the request fails because your session has expired,
  # we'll log in again and retry.
  def request(method, path, options = {})
    response = super

    # If this request has not been retried already, and we received a response status of 412, this may be a case
    # where our session token has expired.  We'll retry the request.
    # NOTE: If Archivematica ever changes its API and returns a different status code,
    # we'll need to update the check below.
    if response.status_code == 412 && options[:retry].nil?
      # Clear any existing token (this is important to do, so that the upcoming login request does not include a token)
      self.token = nil

      # Log in again to generate and store a new token
      self.login

      # Make original request again.  This time it will use the newly generated token.
      # We'll alslo include a retry flag in the options, to protect against infinite recursive loops.
      new_options = options.merge({retry: true})
      response = self.request(method, path, new_options)
    end
    response
  end

  # Splits the given ArchivesSpace resource_record_uri into its constituent repository_id and resource_id.
  # @return [Array] An array of length 2.  The first element is the repository_id and the second is the resource_id.
  def split_resource_record_uri(resource_record_uri)
    matches = RESOURCE_RECORD_URI_REGEXP.match(resource_record_uri)

    if matches.nil?
      raise Acfa::Exceptions::InvalidArchivesSpaceResourceUri,
            'Invalid format resource_record_uri.  Expected a value like: /repositories/2/resources/2024'
    end

    [matches[1], matches[2]] # [repository_id, resource_id]
  end

  def bib_id_for_resource(resource_record_uri:)
    #self.login
    repository_id, resource_id = split_resource_record_uri(resource_record_uri)
    response = self.get("/repositories/#{repository_id}/resources/#{resource_id}")
    raise_error_if_unsuccessful_archivesspace_response!(__method__, response)
    parsed_response = JSON.parse(response.body)
    parsed_response.fetch('id_0')
  end

  def download_ead(resource_record_uri:, filename:, include_unpublished:)
    #self.login
    repository_id, resource_id = split_resource_record_uri(resource_record_uri)
    download_path = File.join(CONFIG[:ead_cache_dir], filename)

    response = self.get(
      "/repositories/#{repository_id}/resource_descriptions/#{resource_id}.xml",
      query: { include_unpublished: include_unpublished, include_daos: true }
    )
    raise_error_if_unsuccessful_archivesspace_response!(__method__, response)

    # Validate the downloaded EAD's XML (just the validity of the xml markup, not the schema)
    xml_content = response.body
    xml_is_valid = Nokogiri::XML(xml_content).errors.blank?
    raise Acfa::Exceptions::InvalidEadXml, 'Downloaded EAD did not pass XML validation.' if !xml_is_valid

    download_time = Benchmark.measure { File.binwrite(download_path, xml_content) }.real
    Rails.logger.debug("Downloaded EAD to #{download_path}.  Took #{download_time} seconds.")

    download_path
  end

  def raise_error_if_unsuccessful_archivesspace_response!(context_label, response)
    return if response.status_code == 200

    Rails.logger.error("#{context_label}: request returned a status of #{response.status_code}.  Response: #{response.body}")

    raise Acfa::Exceptions::UnexpectedArchivesSpaceApiResponse,
    "Unexpected response from ArchivesSpace (status: #{response.status_code}). "\
    'Check application log for more details.'
  end
end
