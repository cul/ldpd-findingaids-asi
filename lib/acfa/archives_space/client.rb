class Acfa::ArchivesSpace::Client
  def initialize(base_uri:, username:, password:)
    @base_uri = base_uri
    @username = username
    @password = password
  end

  def internal_client
    unless @internal_client
      @internal_client = ArchivesSpace::Client.new(
        ArchivesSpace::Configuration.new({
          base_uri: @base_uri,
          username: @username,
          password: @password,
          timeout: 600
        })
      )
      @internal_client.login
    end

    @internal_client
  end

  # Splits the given resource_uri into its constituent repository_id and resource_id.
  # @return [Array] An array of length 2.  The first element is the repository_id and the second is the resource_id.
  def split_resource_uri(resource_uri)
    # Validate and parse params ###############################################
    resource_uri_regexp = /^\/*repositories\/(\d+)\/resources\/(\d+)$/
    matches = resource_uri_regexp.match(resource_uri)

    if matches.nil?
      raise Acfa::Exceptions::InvalidArchivesSpaceResourceUri,
            'Invalid format resource_uri.  Expected a value like: /repositories/2/resources/2024'
    end

    [matches[1], matches[2]] # [repository_id, resource_id]
  end

  def bib_id_for_resource(resource_uri:)
    repository_id, resource_id = split_resource_uri(resource_uri)
    JSON.parse(internal_client.get("/repositories/#{repository_id}/resources/#{resource_id}").body).fetch('id_0')
  end

  def download_ead(resource_uri:, filename:, include_unpublished:)
    repository_id, resource_id = split_resource_uri(resource_uri)
    download_path = File.join(CONFIG[:ead_cache_dir], filename)

    ead_response = internal_client.get(
      "/repositories/#{repository_id}/resource_descriptions/#{resource_id}.xml",
      query: { include_unpublished: include_unpublished, include_daos: true }
    )

    # Validate the downloaded EAD's XML (just the validity of the xml markup, not the schema)
    xml_content = ead_response.body
    xml_is_valid = Nokogiri::XML(xml_content).errors.blank?

    raise Acfa::Exceptions::InvalidEadXml, 'Downloaded EAD did not pass XML validation.' if !xml_is_valid
    download_time = Benchmark.measure { File.binwrite(download_path, xml_content) }.real
    Rails.logger.debug("Downloaded EAD to #{download_path}.  Took #{download_time} seconds.")

    download_path
  end
end
