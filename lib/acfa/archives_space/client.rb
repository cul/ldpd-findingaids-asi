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
    repository_id, resource_id = split_resource_record_uri(resource_record_uri)
    response = JSON.parse(self.get("/repositories/#{repository_id}/resources/#{resource_id}").body)
    response.fetch('id_0')
  end

  def download_ead(resource_record_uri:, filename:, include_unpublished:)
    repository_id, resource_id = split_resource_record_uri(resource_record_uri)
    download_path = File.join(CONFIG[:ead_cache_dir], filename)

    ead_response = self.get(
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
