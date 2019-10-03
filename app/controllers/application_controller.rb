require 'archive_space'
require 'open-uri'
class ApplicationController < ActionController::Base
  include  ArchiveSpace::Ead::MarcHelper

  before_action :set_preview_flag, :set_print_view_flag

  attr_accessor :authenticity_token

  private
  def ead_series_set_properties component_num
    component_nokogiri_xml = @ead.dsc_series[component_num.to_i - 1]
    @component = ArchiveSpace::Ead::EadComponentParser.new
    @component.parse component_nokogiri_xml
    @component_title = @component.title
    @notes = @component.notes
    @daos_description_href = @component.digital_archival_objects_description_href
    @flattened_component_structure = @component.generate_info
  end

  # @as_repo_id => repo ID in ArchiveSpace
  def validate_repository_code_and_set_repo_id
    if REPOS.key? params[:repository_id]
      @as_repo_id = REPOS[params[:repository_id]][:as_repo_id]
      @repository_name = REPOS[params[:repository_id]][:name]
    else
      Rails.logger.warn("Non-existent repo code in url, redirect to home page")
      # for now, redirect to root. Change later
      redirect_to '/'
    end
  end

  def redirect_if_publish_flag_false(bib_id)
    initialize_as_api
    @as_resource_id = @as_api.get_resource_id(@as_repo_id, bib_id)
    unless @as_api.get_resource_info(@as_repo_id, @as_resource_id).publish_flag
      Rails.logger.warn("AS ID #{@as_resource_id} (Bib ID #{bib_id}): publish flag false, DON'T DISPLAY")
      redirect_to '/'
      return
    end
  end

  def cached_as_ead(bib_id)
    ead_cache_paths = Dir[CONFIG[:ead_cache_dir] + "/*_ead_ldpd_#{bib_id}.xml"].sort
    if ead_cache_paths.first && File.exist?(ead_cache_paths.first)
      cached_file = ead_cache_paths.first
      Rails.logger.info("EAD cached file #{File.basename cached_file} exists")
      open(cached_file) do |b|
        b.read
      end
    else
      Rails.logger.warn("EAD cached file *_ead_ldpd_#{bib_id}.xml DOES NOT exist, AS API call required")
      initialize_as_api
      @as_resource_id = @as_api.get_resource_id(@as_repo_id, bib_id)
      if @as_api.get_resource_info(@as_repo_id, @as_resource_id).publish_flag
        as_ead = @as_api.get_ead_resource_description(@as_repo_id, @as_resource_id)
        cached_file = File.join(CONFIG[:ead_cache_dir], "as_ead_ldpd_#{bib_id}.xml")
      else
        as_ead = stub_ead_from_clio(bib_id)
        unless as_ead.present?
          Rails.logger.warn("AS ID #{@as_resource_id} (Bib ID #{bib_id}): publish flag false, DON'T DISPLAY")
          redirect_to '/'
          return
        end
        cached_file = File.join(CONFIG[:ead_cache_dir], "clio_ead_ldpd_#{bib_id}.xml")
      end
      File.open(cached_file, "wb") do |file|
        file.write(as_ead)
      end
      as_ead
    end
  end

  # stub ead from a bib id per the legacy ACFA app
  # see marc_helper
  # return nil if bib_id is nil or if it does not resolve to a collection record in CLIO
  def stub_ead_from_clio(bib_id)
    return unless bib_id.present?
    marc21_url = clio_url_for(bib_id, "marc")
    marc_record = MARC::Record.new_from_marc(URI(marc21_url).read)
    stub_ead(marc_record)
  rescue Exception => ex
    Rails.logger.error(ex)
    return nil
  end

  def clio_url_for(bib_id, format = nil)
    url = "https://clio.columbia.edu/catalog/#{bib_id}"
    url << ".#{format}" if format
    url
  end

  def cache_response_html
    if @dsc_all
      cached_file = File.join(CONFIG[:html_cache_dir], "ldpd_#{@params_bib_id}_all.html")
    else
      cached_file = File.join(CONFIG[:html_cache_dir],
                              "ldpd_#{@params_bib_id}#{@params_series_num ? '_' + @params_series_num : ''}.html")
    end
    if File.exist?(cached_file)
      Rails.logger.info("HTML cached file #{File.basename cached_file} exists")
    else
      Rails.logger.warn("HTML cached file #{File.basename cached_file} DOES NOT exists, saving html")
      cached_response_body = response.body
      cached_response_body = cached_response_body.sub(@authenticity_token, CONFIG[:authenticity_token_placeholder]) if @authenticity_token
      File.open(cached_file, "wb") do |file|
        file.write(cached_response_body)
      end
    end
  end

  def preview_as_ead(bib_id)
    Rails.logger.warn("Preview for ldpd_#{bib_id}, AS API call required with include_unpublished=true")
    initialize_as_api
    @as_resource_id = @as_api.get_resource_id(@as_repo_id, bib_id)
    @as_api.get_ead_resource_description(@as_repo_id, @as_resource_id, true)
  end

  def initialize_as_api
    @as_api = ArchiveSpace::Api::Client.new
  end

  def set_preview_flag
    @preview_flag = request.path.start_with?('/preview')
  end

  def set_print_view_flag
    @print_view = request.path.ends_with?('/print')
  end
end
