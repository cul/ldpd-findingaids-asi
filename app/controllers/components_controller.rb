require 'archive_space/api/client'
require 'archive_space/parsers/component_parser'
require 'archive_space/parsers/archival_description_did_parser'
require 'archive_space/parsers/archival_description_dsc_parser'
require 'archive_space/parsers/archival_description_misc_parser'
require 'archive_space/parsers/ead_header_parser'

class ComponentsController < ApplicationController

  before_action :validate_bid_id_and_set_repo_id, only: [:index, :show]
  after_action :cache_response_html, only: [:index, :show]

  def show
    @authenticity_token = form_authenticity_token
    # @params_bib_id used by html caching functionality and error logging
    @params_bib_id = params[:finding_aid_id].delete_prefix('ldpd_').to_i
    # @params_series_number used by html caching functionality
    @params_series_num = params[:id]
    input_xml = render_cached_html_else_return_as_ead_xml(@params_bib_id, @authenticity_token)
    return unless input_xml
    ead_nokogiri_xml_doc = create_nokogiri_xml_document(input_xml, @params_bib_id)
    # need to parse the <archdesc><dsc> to get the list of top-level <c>s and enclosed second-level <c>s
    # in order to build the lhs sidebar navigation menu. Also used to verify given series number is within range
    @arch_desc_dsc = ArchiveSpace::Parsers::ArchivalDescriptionDscParser.new
    @arch_desc_dsc.parse ead_nokogiri_xml_doc
    # verify given series number (params[:id]) is within range
    unless (params[:id].to_i < @arch_desc_dsc.series_compound_title_array.size + 1 && params[:id].to_i > 0)
      Rails.logger.warn('dsc number from url params out of range')
      redirect_to '/'
      return
    end
    # Need top-level finding aids information for the aeon request, finding aids title, and sidebar
    @arch_desc_did = ArchiveSpace::Parsers::ArchivalDescriptionDidParser.new
    @arch_desc_did.parse ead_nokogiri_xml_doc
    @finding_aid_title =
      [@arch_desc_did.unit_title, @arch_desc_did.unit_dates_string].join(', ')
    # Need to parse miscellaneous info in the <archdesc> in order to get access restrictions. No need to
    # store it in an instance var, the pertinent info is retrieved to set flags below in current method
    @arch_desc_misc = ArchiveSpace::Parsers::ArchivalDescriptionMiscParser.new
    @arch_desc_misc.parse ead_nokogiri_xml_doc
    @restricted_access_flag =
      @arch_desc_misc.access_restrictions_values.map{ |value| ArchiveSpace::Parsers::EadHelper.highlight_offsite value.text }.any?
    @unprocessed_flag =
      @arch_desc_misc.access_restrictions_values.map{ |value| ArchiveSpace::Parsers::EadHelper.accessrestrict_contains_unprocessed? value.text }.any?
    # fcd1, 02/24/20: @subjects and @genres_forms needed for the sidebar view, in order to hide unneeded links.
    # Need to refactor this, possibly into application controller helper method
    @subjects = (@arch_desc_misc.control_access_corporate_name_values +
                 @arch_desc_misc.control_access_occupation_values +
                 @arch_desc_misc.control_access_personal_name_values +
                 @arch_desc_misc.control_access_subject_values).sort
    @genres_forms = @arch_desc_misc.control_access_genre_form_values.sort
    # fcd1, 09/12/19: For now, assume all top-level <c> elements are series. However, when other
    # types of top-level <c> elements are allowed, modify the following code, including changing
    # variable name from @series to, for example, @top_level_component (more generic), or check
    # for the type of component here and create appropriate variable
    @series = ArchiveSpace::Parsers::ComponentParser.new
    @series.parse(ead_nokogiri_xml_doc, @params_series_num.to_i)
    @cache_html = true unless @preview_flag
  end

  def index
    @dsc_all = true
    @authenticity_token = form_authenticity_token
    # @params_bib_id used by html caching functionality and error logging
    @params_bib_id = params[:finding_aid_id].delete_prefix('ldpd_').to_i
    input_xml = render_cached_html_else_return_as_ead_xml(@params_bib_id, @authenticity_token)
    return unless input_xml
    ead_nokogiri_xml_doc = create_nokogiri_xml_document(input_xml, @params_bib_id)
    @arch_desc_did = ArchiveSpace::Parsers::ArchivalDescriptionDidParser.new
    @arch_desc_did.parse ead_nokogiri_xml_doc
    @arch_desc_dsc = ArchiveSpace::Parsers::ArchivalDescriptionDscParser.new
    @arch_desc_dsc.parse ead_nokogiri_xml_doc
    @arch_desc_misc = ArchiveSpace::Parsers::ArchivalDescriptionMiscParser.new
    @arch_desc_misc.parse ead_nokogiri_xml_doc
    @restricted_access_flag =
      @arch_desc_misc.access_restrictions_values.map{ |value| ArchiveSpace::Parsers::EadHelper.highlight_offsite value.text }.any?
    @unprocessed_flag =
      @arch_desc_misc.access_restrictions_values.map{ |value| ArchiveSpace::Parsers::EadHelper.accessrestrict_contains_unprocessed? value.text }.any?
    @ead_header = ArchiveSpace::Parsers::EadHeaderParser.new
    @ead_header.parse ead_nokogiri_xml_doc
    @finding_aid_title =
      [@arch_desc_did.unit_title, @arch_desc_did.unit_dates_string].join(', ')
    @subjects = (@arch_desc_misc.control_access_corporate_name_values +
                 @arch_desc_misc.control_access_occupation_values +
                 @arch_desc_misc.control_access_personal_name_values +
                 @arch_desc_misc.control_access_subject_values).sort
    @genres_forms = @arch_desc_misc.control_access_genre_form_values.sort
    unless (@ead_header.eadid_url_attribute.nil? ||
            @ead_header.eadid_url_attribute.include?('findingaids.cul.columbia.edu') ||
            @ead_header.eadid_url_attribute.include?('findingaids.library.columbia.edu'))
      @eadid_other_finding_aid_url = @ead_header.eadid_url_attribute
    end
    @notes_array = []
    @flattened_component_structure_array = []
    @daos_description_href_array = []
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
    @cache_html = true unless @preview_flag
  end

  # fcd1, 06/22/21: similar to FindingAidsController#validate_bid_id_and_set_repo_id, but using params[:finding_aid_id]
  # instead of params[:id]. Need to refactor some/most/all of this functionality into ApplicationController
  def validate_bid_id_and_set_repo_id
    if params[:finding_aid_id].blank?
      Rails.logger.warn("finding_aid_id parameter is blank")
      redirect_to '/'
      return
    end
    expected_repo_code = retrieve_expected_repo_code(params[:finding_aid_id])
    unless expected_repo_code
      redirect_to CONFIG[:clio_redirect_url] + params[:finding_aid_id].delete_prefix('ldpd_')
      return
    end
    unless expected_repo_code.eql? params[:repository_id]
      if params[:id].present?
        # redirect to components#show
        redirect_to repository_finding_aid_component_path(repository_id: expected_repo_code)
      else
        # redirect to components#index
        redirect_to repository_finding_aid_components_path(repository_id: expected_repo_code)
      end
      return
    end
    @as_repo_id = REPOS[params[:repository_id]][:as_repo_id]
    @repository_name = REPOS[params[:repository_id]][:name]
  end
end
