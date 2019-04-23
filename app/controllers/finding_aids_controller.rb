require 'archive_space/api/client'
require 'archive_space/ead/ead_parser'

class FindingAidsController < ApplicationController
  before_action :validate_repository_code_and_set_repo_id,
                :validate_bib_id_and_set_resource_id

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

  private
  def ead_set_properties
    @ead = ArchiveSpace::Ead::EadParser.new @input_xml
    @title = @ead.archive_title
    @abstract = @ead.archive_abstract
    @bib_id = @ead.archive_id
    @creators = @ead.get_creators
    @unit_date = @ead.archive_date
    @physical_description = @ead.archive_physical_description_extent_carrier
    @language = @ead.archive_language
    @access_restrictions_head = @ead.archive_access_restrictions_head
    @access_restrictions_value = @ead.archive_access_restrictions_value
    @scope_content_head = @ead.archive_scope_content_head
    @scope_content_values = @ead.archive_scope_content_values
    @repository_corpname = @ead.archive_repository
    @preferred_citation_head = @ead.archive_preferred_citation_head
    @preferred_citation_value = @ead.archive_preferred_citation_value
    @use_restrictions_head = @ead.archive_use_restrictions_head
    @use_restrictions_value = @ead.archive_use_restrictions_value
    @processing_information_head = @ead.archive_processing_information_head
    @processing_information_value = @ead.archive_processing_information_value
    @biography_history_head = @ead.archive_biography_history_head
    @biography_history_values = @ead.archive_biography_history_values
    @series_titles = @ead.archive_dsc_series_titles
    @series_scope_content = @ead.get_series_scope_content
    @subjects = @ead.get_subjects
    @genres_forms = @ead.get_genres_forms
  end

  # @as_resource_id => resource ID in ArchiveSpace
  def validate_bib_id_and_set_resource_id
     @as_api = ArchiveSpace::Api::Client.new
     bib_id = params[:id].delete_prefix('ldpd_').to_i
     puts bib_id
    if CONFIG[:use_fixtures]
      @as_resource_id = @as_api.get_resource_id_local_fixture(bib_id)
    else
      @as_respource_id = @as_api.get_resource_id(bib_id)
    end

    # not currently displaying contents of flash, but may be useful
      # when redirect to other than root
    # flash[:error] = 'Non-existent repo code in url'
      # for now, redirect to root. Change later
    # redirect_to '/'
  end
end
