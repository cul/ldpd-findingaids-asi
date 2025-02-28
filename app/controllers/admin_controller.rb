class AdminController < ApplicationController
  before_action :authenticate_user!

  # GET /admin
  def index
  end

  # POST /admin/refresh_resource
  def refresh_resource
    # TODO: Validate format of provided id.  It should look like this: '/repositories/2/resources/2024'
    resource_uri = params[:resource_record_uri]
    include_unpublished = params[:include_unpublished] == 'true'

    client = ArchivesSpace::Client.new(
      ArchivesSpace::Configuration.new({
        base_uri: ARCHIVESSPACE[:base_uri],
        username: ARCHIVESSPACE[:username],
        password: ARCHIVESSPACE[:password],
        timeout: 600
      })
    ).login

    resource_uri_regexp = /^\/*repositories\/(\d+)\/resources\/(\d+)$/
    matches = resource_uri_regexp.match(resource_uri)

    if matches.nil?
      render json: {result: false, error: 'Invalid format resource_uri.  Expected a value like: /repositories/2/resources/2024'}
      return
    else
      repository_id = matches[1]
      resource_id = matches[2]
    end

    bib_id = JSON.parse(client.get("/repositories/#{repository_id}/resources/#{resource_id}").body).fetch('id_0')

    ead_response = client.get(
      "/repositories/#{repository_id}/resource_descriptions/#{resource_id}.xml",
      query: {
        include_unpublished: include_unpublished,
        include_daos: true
      }
    )
    ead_filename = "as_ead_cul-#{bib_id}.xml"
    full_ead_file_path = File.join(CONFIG[:ead_cache_dir], ead_filename)

    download_time = Benchmark.measure {
      File.binwrite(full_ead_file_path, ead_response.body)
    }.real

    puts "download_time: #{download_time}"

    index_time = Benchmark.measure {
      IndexEadJob.perform_now(ead_filename)
    }.real

    puts "index_time: #{index_time}"

    render json: {result: true, resource_id: "cul-#{bib_id}"}
  rescue Net::ReadTimeout
    render json: {result: false, error: 'ArchivesSpace EAD download took too long and the request timed out.'}
  end
end
