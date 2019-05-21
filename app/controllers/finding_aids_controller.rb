require 'archive_space/api/client'
require 'archive_space/ead/ead_parser'

class FindingAidsController < ApplicationController
  before_action :set_bib_id,
                :validate_repository_code_and_set_repo_id,
                :validate_bib_id_and_set_resource_id,
                only: [:show]

  def index
  end

  def show
    if CONFIG[:use_fixtures]
      @input_xml =
        # @as_api.get_ead_resource_description_from_local_fixture(@as_repo_id,params[:id])
        @as_api.get_ead_resource_description_from_local_fixture(@as_repo_id,@as_resource_id)
    else
      # @input_xml = @as_api.get_ead_resource_description(@as_repo_id,params[:res_id])
      @input_xml = @as_api.get_ead_resource_description(@as_repo_id,@as_resource_id)
    end
    ead_set_properties
  end

  def summary
    redirect_to repository_finding_aid_path(id: params[:finding_aid_id])
  end

  private
  def ead_set_properties
    @ead = ArchiveSpace::Ead::EadParser.new @input_xml
    @finding_aid_title = @ead.unit_title
    @abstract = @ead.abstract
    @bib_id = @ead.id
    @creators = @ead.origination_creators
    @unit_date = @ead.date
    @physical_description = @ead.physical_description_extent_carrier
    @language = @ead.language
    @access_restrictions_head = @ead.access_restrictions_head
    @access_restrictions_values = @ead.access_restrictions_values
    @accruals_head = @ead.accruals_head
    @accruals_values = @ead.accruals_values
    @alternative_form_available_head = @ead.alternative_form_available_head
    @alternative_form_available_values = @ead.alternative_form_available_values
    @scope_content_head = @ead.scope_content_head
    @scope_content_values = @ead.scope_content_values
    @repository_corpname = @ead.repository
    @odd_head = @ead.odd_head
    @odd_values = @ead.odd_values
    @preferred_citation_head = @ead.preferred_citation_head
    @preferred_citation_values = @ead.preferred_citation_values
    @use_restrictions_head = @ead.use_restrictions_head
    @use_restrictions_values = @ead.use_restrictions_values
    @processing_information_head = @ead.processing_information_head
    @processing_information_values = @ead.processing_information_values
    @related_material_head = @ead.related_material_head
    @related_material_values = @ead.related_material_values
    @biography_history_head = @ead.biography_history_head
    @biography_history_values = @ead.biography_history_values
    @revision_description_changes = @ead.revision_description_changes
    @separated_material_head = @ead.separated_material_head
    @separated_material_values = @ead.separated_material_values
    @series_titles = @ead.dsc_series_titles
    @series_scope_content = @ead.get_series_scope_content
    @subjects = (@ead.control_access_corpnames +
                @ead.control_access_occupations +
                @ead.control_access_persnames +
                @ead.control_access_subjects).sort
    @genres_forms = @ead.control_access_genres_forms.sort
  end

  def set_bib_id
    @bib_id = params[:id].delete_prefix('ldpd_').to_i
  end
end
