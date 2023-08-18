require 'archive_space/api/client'
require 'archive_space/parsers/archival_description_did_parser'
require 'archive_space/parsers/archival_description_dsc_parser'
require 'archive_space/parsers/archival_description_misc_parser'
require 'archive_space/parsers/ead_header_parser'
require 'archive_space/parsers/component_parser'

class FindingAidsController < ApplicationController

  before_action :validate_bid_id_and_set_repo_id, only: [:print, :show]
  before_action :validate_repository_code_and_set_repo_id, only: [:index]
  after_action :cache_response_html, only: [:show, :print]

  def index
    @repo_id = params[:repository_id]
    begin
      @fa_list = ActionController::Base.render(inline: File.read("#{CONFIG[:fa_lists_dir]}/#{@repo_id}_fa_list.html"), layout: false)
    rescue ActionView::MissingTemplate
      # If file "#{CONFIG[:fa_lists_dir]}/#{@repo_id}_fa_list.html" does not exist,
      # rails throws ActionView::MissingTemplate
      Rails.logger.warn("no fa_list file for the given repo: #{@repo_id}")
      redirect_to '/'
    end
  end

  def show
    # @params_bib_id used by html caching functionality and error logging
    @params_bib_id = params[:id].delete_prefix('ldpd_').to_i
    input_xml = render_cached_html_else_return_as_ead_xml @params_bib_id
    return unless input_xml
    ead_nokogiri_xml_doc = create_nokogiri_xml_document(input_xml, @params_bib_id)
    ArchiveSpace::Parsers::EadHelper.insert_html_list_elements ead_nokogiri_xml_doc
    ArchiveSpace::Parsers::EadHelper.insert_html_italics ead_nokogiri_xml_doc
    @arch_desc_did = ArchiveSpace::Parsers::ArchivalDescriptionDidParser.new
    @arch_desc_did.parse ead_nokogiri_xml_doc
    @arch_desc_dsc = ArchiveSpace::Parsers::ArchivalDescriptionDscParser.new
    @arch_desc_dsc.parse ead_nokogiri_xml_doc
    @arch_desc_misc = ArchiveSpace::Parsers::ArchivalDescriptionMiscParser.new
    @arch_desc_misc.parse ead_nokogiri_xml_doc
    # ACFA-352: fcd1, 03/04/22. Populate @arch_desc_misc.access_restrictions_head
    # for repos RMBL/UA/OH because finding aid will display standard info about making
    # appointment in Restrictions on Access section, even if EAD does not contain any
    # Restriction on Access info (and thus the section header would normally not be present).
    if (['nnc-rb', 'nnc-ua', 'nnc-ccoh'].include?(@repository_code) &&
        @arch_desc_misc.access_restrictions_head.blank?)
      @arch_desc_misc.access_restrictions_head = 'Restrictions on Access'
    end
    @ead_header = ArchiveSpace::Parsers::EadHeaderParser.new
    @ead_header.parse ead_nokogiri_xml_doc
    @finding_aid_title =
      [@arch_desc_did.unit_title, @arch_desc_did.unit_dates_string].join(', ')
    @subjects = (@arch_desc_misc.control_access_corporate_name_values +
                 @arch_desc_misc.control_access_geographic_name_values +
                 @arch_desc_misc.control_access_occupation_values +
                 @arch_desc_misc.control_access_personal_name_values +
                 @arch_desc_misc.control_access_subject_values).sort
    @genres_forms = @arch_desc_misc.control_access_genre_form_values.sort
    @restricted_access_flag =
      @arch_desc_misc.access_restrictions_values.map{ |value| ArchiveSpace::Parsers::EadHelper.highlight_offsite value.text }.any?
    @unprocessed_flag =
      @arch_desc_misc.access_restrictions_values.map{ |value| ArchiveSpace::Parsers::EadHelper.accessrestrict_contains_unprocessed? value.text }.any?
    unless (@ead_header.eadid_url_attribute.nil? ||
            @ead_header.eadid_url_attribute.include?('findingaids.cul.columbia.edu') ||
            @ead_header.eadid_url_attribute.include?('findingaids.library.columbia.edu'))
      @eadid_other_finding_aid_url = @ead_header.eadid_url_attribute
    end
    @cache_html = CONFIG.fetch(:cache_html, !@preview_flag)
  end

  def print
    @print_view = true
    # @params_bib_id used by html caching functionality
    @params_bib_id = params[:finding_aid_id].delete_prefix('ldpd_').to_i
    input_xml = render_cached_html_else_return_as_ead_xml @params_bib_id
    return unless input_xml
    ead_nokogiri_xml_doc = create_nokogiri_xml_document(input_xml, @params_bib_id)
    ArchiveSpace::Parsers::EadHelper.insert_html_list_elements ead_nokogiri_xml_doc
    ArchiveSpace::Parsers::EadHelper.insert_html_italics ead_nokogiri_xml_doc
    @arch_desc_did = ArchiveSpace::Parsers::ArchivalDescriptionDidParser.new
    @arch_desc_did.parse ead_nokogiri_xml_doc
    @arch_desc_dsc = ArchiveSpace::Parsers::ArchivalDescriptionDscParser.new
    @arch_desc_dsc.parse ead_nokogiri_xml_doc
    @arch_desc_misc = ArchiveSpace::Parsers::ArchivalDescriptionMiscParser.new
    @arch_desc_misc.parse ead_nokogiri_xml_doc
    @ead_header = ArchiveSpace::Parsers::EadHeaderParser.new
    @ead_header.parse ead_nokogiri_xml_doc
    @finding_aid_title =
      [@arch_desc_did.unit_title, @arch_desc_did.unit_dates_string].join(', ')
    @subjects = (@arch_desc_misc.control_access_corporate_name_values +
                 @arch_desc_misc.control_access_geographic_name_values +
                 @arch_desc_misc.control_access_occupation_values +
                 @arch_desc_misc.control_access_personal_name_values +
                 @arch_desc_misc.control_access_subject_values).sort
    @genres_forms = @arch_desc_misc.control_access_genre_form_values.sort
    @series_array = []
    @arch_desc_dsc.series_compound_title_array.each_with_index do |title, index|
      # fcd1, 09/12/19: For now, assume all top-level <c> elements are series. However, when other
      # types of top-level <c> elements are allowed, modify the following code, including changing
      # variable name from a_series to, for example, a_top_level_component (more generic), or check
      # for the type of component here and create appropriate variable
      current_series = ArchiveSpace::Parsers::ComponentParser.new
      current_series.parse(ead_nokogiri_xml_doc, index + 1)
      @series_array.append current_series
    end
    @cache_html = CONFIG.fetch(:cache_html, !@preview_flag)
  end

  def summary
    if @preview_flag
      redirect_to '/preview' + repository_finding_aid_path(id: params[:finding_aid_id])
    else
      redirect_to repository_finding_aid_path(id: params[:finding_aid_id])
    end
  end

  def resolve
    unless params[:id].blank?
      bib_id = params[:id].delete_prefix('ldpd_')
      repo_id = bib_id_repo_id_hash.fetch(bib_id.to_i) do
        redirect_to CONFIG[:clio_redirect_url] + bib_id
        return
      end
      redirect_to repository_finding_aid_path(repository_id: repo_id, id: bib_id.prepend('ldpd_'))
    else
      Rails.logger.warn("no Bib ID in url")
      redirect_to '/'
    end
  end

  def validate_bid_id_and_set_repo_id
    params[:id] = params[:finding_aid_id] if request.path.ends_with?('/print')
    if params[:id].blank?
      Rails.logger.warn("id parameter is blank")
      redirect_to '/'
      return
    end
    expected_repo_code = retrieve_expected_repo_code(params[:id])
    unless expected_repo_code
      redirect_to CONFIG[:clio_redirect_url] + params[:id].delete_prefix('ldpd_')
      return
    end
    unless expected_repo_code.eql? params[:repository_id]
      if request.path.ends_with?('/print')
        redirect_to repository_finding_aid_print_path(repository_id: expected_repo_code)
      else
        redirect_to repository_finding_aid_path(repository_id: expected_repo_code)
      end
      return
    end
    validate_repository_code_and_set_repo_id
  end
end
