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
    @finding_aid_title = @ead.archive_title
    @abstract = @ead.archive_abstract
    @bib_id = @ead.archive_id
    @creators = @ead.archive_origination_creator
    @unit_date = @ead.archive_date
    @physical_description = @ead.archive_physical_description_extent_carrier
    @language = @ead.archive_language
    @access_restrictions_head = @ead.archive_access_restrictions_head
    @access_restrictions_values = @ead.archive_access_restrictions_values
    @accruals_head = @ead.archive_accruals_head
    @accruals_values = @ead.archive_accruals_values
    @alternative_form_available_head = @ead.archive_alternative_form_available_head
    @alternative_form_available_values = @ead.archive_alternative_form_available_values
    @scope_content_head = @ead.archive_scope_content_head
    @scope_content_values = @ead.archive_scope_content_values
    @repository_corpname = @ead.archive_repository
    @preferred_citation_head = @ead.archive_preferred_citation_head
    @preferred_citation_values = @ead.archive_preferred_citation_values
    @use_restrictions_head = @ead.archive_use_restrictions_head
    @use_restrictions_values = @ead.archive_use_restrictions_values
    @processing_information_head = @ead.archive_processing_information_head
    @processing_information_values = @ead.archive_processing_information_values
    @related_material_head = @ead.archive_related_material_head
    @related_material_values = @ead.archive_related_material_values
    @biography_history_head = @ead.archive_biography_history_head
    @biography_history_values = @ead.archive_biography_history_values
    @revision_description_changes = @ead.archive_revision_description_changes
    @series_titles = @ead.archive_dsc_series_titles
    @series_scope_content = @ead.get_series_scope_content
    @subjects = @ead.get_subjects
    @genres_forms = @ead.get_genres_forms
  end

  def set_bib_id
    @bib_id = params[:id].delete_prefix('ldpd_').to_i
  end
end
