require 'archive_space/api/client'
require 'archive_space/ead/ead_parser'

class FindingAidsController < ApplicationController
  include  ArchiveSpace::Ead::EadHelper

  before_action :validate_repository_code_and_set_repo_id, only: [:index, :show]
  before_action :initialize_as_api,
                :get_as_resource_info,
                only: [:show]

  def index
    @repo_id = params[:repository_id]
    @finding_aids_titles_bib_ids = REPOS[@repo_id][:list_of_finding_aids]
  end

  def show
    if @preview_flag
      Rails.logger.warn("Using Preview for #{params[:id]}")
      @input_xml = preview_as_ead params[:id].delete_prefix('ldpd_').to_i
    else
      Rails.logger.warn("Using Cache for #{params[:id]}")
      @input_xml = cached_as_ead params[:id].delete_prefix('ldpd_').to_i
    end
    # @mtime = @as_api.get_resource_mtime(@as_repo_id, @as_resource_id)
    ead_set_properties
  end

  def summary
    if @preview_flag
      redirect_to '/preview' + repository_finding_aid_path(id: params[:finding_aid_id])
    else
      redirect_to repository_finding_aid_path(id: params[:finding_aid_id])
    end
  end

  private
  def ead_set_properties
    @ead = ArchiveSpace::Ead::EadParser.new @input_xml
    @finding_aid_title =
      [@ead.unit_title, @ead.compound_dates_into_string(@ead.unit_dates)].join(', ')
    @bib_id = @ead.unit_id
    @physical_description_string = compound_physical_descriptions_into_string @ead.physical_descriptions
    @series_titles = @ead.dsc_series_titles
    @subseries_titles = @ead.subseries_titles
    @series_scope_content = @ead.get_series_scope_content
    @subjects = (@ead.control_access_corpnames +
                @ead.control_access_occupations +
                @ead.control_access_persnames +
                @ead.control_access_subjects).sort
    @genres_forms = @ead.control_access_genres_forms.sort
    @restricted_access_flag =
      @ead.access_restrictions_values.map{ |value| hightlight_offsite value.text }.any?
  end

  def get_as_resource_info
    bib_id = params[:id].delete_prefix('ldpd_').to_i
    if CONFIG[:use_fixtures]
      @as_resource_id = @as_api.get_resource_id_local_fixture(bib_id)
    else
      @as_resource_id = @as_api.get_resource_id(@as_repo_id, bib_id)
    end
    unless @as_resource_id
      Rails.logger.warn('bib ID does not resolve to AS resource')
      redirect_to '/'
      return
    end
    unless CONFIG[:use_fixtures]
      @as_resource_info = @as_api.get_resource_info(@as_repo_id, @as_resource_id)
      Rails.logger.warn("AS resource #{@as_resource_id} system_mtime: #{@as_resource_info.modified_time}")
      Rails.logger.warn("AS resource #{@as_resource_id} publish: #{@as_resource_info.publish_flag}")
      unless @as_resource_info.publish_flag
        # fcd1, 06/17/19: For now, don't combine above conditional and below conditional in compound statement
        # because want to log specific messages for info/debug purposes
        if @preview_flag
          Rails.logger.warn("AS ID #{@as_resource_id} (Bib ID #{bib_id}): publish flag false, preview mode, DISPLAY")
        else
          Rails.logger.warn("AS ID #{@as_resource_id} (Bib ID #{bib_id}): publish flag false, DON'T DISPLAY")
          redirect_to '/'
          return
        end
      end
    end
  end
end
