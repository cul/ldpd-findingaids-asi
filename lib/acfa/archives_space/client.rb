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

  def download_ead(repository_id:, resource_id:, download_directory_path:)
    bib_id = JSON.parse(internal_client.get("/repositories/#{repository_id}/resources/#{resource_id}").body).fetch('id_0')
    ead_response = internal_client.get(
      "/repositories/#{repository_id}/resource_descriptions/#{resource_id}.xml",
      query: {
        include_unpublished: include_unpublished,
        include_daos: true
      }
    )
    ead_filename = "as_ead_cul-#{bib_id}.xml"
    full_ead_file_path = File.join(CONFIG[:ead_cache_dir], ead_filename)

    # Validate this XML (just the markup, not the schema)
    xml_is_valid = Nokogiri::XML(ead_response.body).errors.blank?

    if !xml_is_valid
      render json: {result: false, error: 'Downloaded EAD did not pass XML validation.'}
      return
    end

    download_time = Benchmark.measure {
      File.binwrite(full_ead_file_path, ead_response.body)
    }.real

    puts "download_time: #{download_time}"

    full_ead_file_path
  end
end
