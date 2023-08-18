require 'archive_space'
require 'open-uri'
class ApplicationController < ActionController::Base
  include  ArchiveSpace::Ead::MarcHelper
  include Acfa::EadParsingController
  include Blacklight::Controller

  before_action :set_preview_flag, :set_print_view_flag

  attr_accessor :authenticity_token

  private
  def create_nokogiri_xml_document(input_xml, bib_id)
    begin
      # turn RECOVER parse option off. Will throw a Nokogiri::XML::SyntaxError if parsing error encountered
      nokogiri_document = Nokogiri::XML(input_xml) do |config|
        config.norecover
      end
    rescue Nokogiri::XML::SyntaxError => e
      Rails.logger.error("Bib ID #{bib_id}, Nokogiri parsing error:")
      Rails.logger.error("Nokogiri::XML::SyntaxError: #{e}")
      Rails.logger.error("Using Nokogiri recover mode for #{bib_id}")
      # Nokogiri RECOVER parsing mode is recommended for malformed or invalid documents
      # The RECOVER parse option is set by default, where Nokogiri will attempt to recover from errors
      # However, the recovery process will entail some loss of information due to the parsing error
      nokogiri_xml = Nokogiri::XML(input_xml)
    end
  end

  # @as_repo_id => repo ID in ArchiveSpace
  def validate_repository_code_and_set_repo_id
    @repository = Repository.find(params[:repository_id])
    @repository_code = @repository.id
    @as_repo_id = @repository.as_repo_id
    @repository_name = @repository.name
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn(e.message)
    unless params[:id].blank?
      bib_id = params[:id].delete_prefix('ldpd_')
      Rails.logger.warn("redirect to CLIO with Bib ID #{bib_id}")
      redirect_to CONFIG[:clio_redirect_url] + bib_id
    else
      Rails.logger.warn("no Bib ID in url")
      redirect_to '/'
    end
  end

  def bib_id_repo_id_hash
    Rails.cache.fetch("bib_id_repo_id_hash", expires_in: CONFIG[:bib_id_repo_id_hash_cache_expiration_in_hours].hours) do
      Rails.logger.warn("Refreshing bib ID repo ID hash via reading file at #{CONFIG[:valid_finding_aid_bib_ids]}") if CONFIG[:log_bib_id_repo_id_hash_cache_expiration]
      HashWithIndifferentAccess.new(YAML.load_file(CONFIG[:valid_finding_aid_bib_ids]))
    end
  end

  # returns nil if cached html is rendered or no info is found (AS EAD or CLIO Stub info)
  # Else, it returns an AS EAD XML file from one of the following sources:
  # 1) First, see if there is an AS EAD XML for this bib ID in the cache. Note that this
  # cached file will have been generated either from step 2) or step 3)
  # 2) If no cached file found, query the AS server for the EAD. If one is returned, cache it
  # 3) if the AS server does not return an EAD, try to generate on from information retrieved from CLIO
  # if such info is found, generate a barebones AS EAD XML stand-in file and cache it.
  # fcd1, 01/16/20: However, I'd prefer to decouple the CLIO stub from the AS EAD XML
  # one way is to return a hash, that either contains an :as_ead key with AS EAD XML has the value,
  # or a :clio_stub key with clio info in a to-be-determined format, probably a hash.
  def render_cached_html_else_return_as_ead_xml(bib_id, authenticity_token = nil)
    if @preview_flag
      Rails.logger.info("Using Preview for BIB ID #{bib_id}")
      preview_as_ead bib_id
    else
      cached_html_filename = generate_cached_html_filename bib_id
      if File.exist?(cached_html_filename)
        Rails.logger.info("Using Cached HTML file for #{bib_id}")
        cached_html_file = open(cached_html_filename) do |file|
          file.read
        end
        cached_html_file.sub!(CONFIG[:authenticity_token_placeholder], form_authenticity_token) if authenticity_token
        render html: cached_html_file.html_safe
        return
      else
        Rails.logger.warn("Using EAD Cache for BIB ID #{bib_id}")
        cached_as_ead bib_id
      end
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
      if @as_repo_id == 'clio_only'
        # redundant, but still explicitly set to nil for self-explanatory code
        @as_resource_id = nil
        Rails.logger.warn("CLIO-only repo (no data for this repo in the ArchiveSpace server)")
      else
        initialize_as_api
        @as_resource_id = @as_api.get_resource_id(@as_repo_id, bib_id)
      end
      if @as_resource_id && @as_api.get_resource_info(@as_repo_id, @as_resource_id).publish_flag
        as_ead = @as_api.get_ead_resource_description(@as_repo_id, @as_resource_id)
        cached_file = File.join(CONFIG[:ead_cache_dir], "as_ead_ldpd_#{bib_id}.xml")
      else
        as_ead = stub_ead_from_clio(bib_id) if Clio::BibIds.generate_stub?(bib_id)
        unless as_ead.present?
          Rails.logger.warn("AS ID #{@as_resource_id} (Bib ID #{bib_id}): no CLIO stub, redirect to CLIO")
          redirect_to CONFIG[:clio_redirect_url] + bib_id.to_s
          return
        else
          Rails.logger.warn("AS ID #{@as_resource_id} (Bib ID #{bib_id}): stubbed from CLIO")
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
    if marc_record.leader[7] == 'c'
      Rails.logger.info("BIB ID #{bib_id}: generating clio stub")
    else
      Rails.logger.warn("BIB ID #{bib_id}: not a collection: #{marc_record.leader}")
      return nil
    end
    stub_ead(marc_record)
  rescue Exception => ex
    Rails.logger.error("#stub_ead_from_clio encountered following error for BIB ID #{bib_id}: #{ex}")
    Rails.logger.debug(ex.backtrace.join("\n"))
    return nil
  end

  def clio_url_for(bib_id, format = nil)
    url = "https://clio.columbia.edu/catalog/#{bib_id}"
    url << ".#{format}" if format
    url
  end

  def cache_response_html
    return unless @cache_html
    cached_htlm_filename = generate_cached_html_filename @params_bib_id
    if File.exist?(cached_htlm_filename)
      Rails.logger.info("HTML cached file #{File.basename cached_htlm_filename} exists")
    else
      Rails.logger.warn("HTML cached file #{File.basename cached_htlm_filename} DOES NOT exists, saving html")
      cached_response_body = response.body
      cached_response_body = cached_response_body.sub(@authenticity_token, CONFIG[:authenticity_token_placeholder]) if @authenticity_token
      File.open(cached_htlm_filename, "wb") do |file|
        file.write(cached_response_body)
      end
    end
  end

  def generate_cached_html_filename(bib_id)
    if @dsc_all
      suffix = '_all.html'
    elsif @print_view
      suffix = '_print.html'
    else
      suffix = "#{@params_series_num ? '_' + @params_series_num : ''}.html"
    end
    File.join(CONFIG[:html_cache_dir], "ldpd_#{bib_id}#{suffix}")
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

  def retrieve_expected_repo_code(finding_aid_id)
    bib_id = finding_aid_id.delete_prefix('ldpd_')
    expected_repo_code = bib_id_repo_id_hash.fetch(bib_id.to_i, false)
  end

  def assign_control_access_terms!(arch_desc_misc)
    @name_terms = names_for_archdesc(arch_desc_misc)
    @place_terms = places_for_archdesc(arch_desc_misc)
    @subjects = subjects_for_archdesc(arch_desc_misc)
    @genres_forms = arch_desc_misc.control_access_genre_form_values.sort
  end
end
