require 'archive_space/api/client'
require 'archive_space/ead/ead_parser'
require 'archive_space/ead/ead_component_parser'

class ComponentsController < ApplicationController
  before_action :validate_repository_code_and_set_repo_id
  def index
  end

  def show
    @as_api = ArchiveSpace::Api::Client.new
    if CONFIG[:use_fixtures]
      @input_xml =
        @as_api.get_ead_resource_description_from_local_fixture(@as_repo_id,params[:finding_aid_id])
    else
      @input_xml = @as_api.get_ead_resource_description(@as_repo_id,params[:finding_aid_id])
    end
    ead_series_set_properties params[:id]
  end

  private
  def ead_series_set_properties component_num
    @ead = ArchiveSpace::Ead::EadParser.new @input_xml
    @series_files_info = @ead.get_files_info_for_series component_num
    # @ead_series_titles is repeated in above method, so try to DRY
    @series_titles = @ead.archive_dsc_series_titles
    component_nokogiri_xml = @ead.archive_dsc_series[component_num.to_i - 1]
    @component = ArchiveSpace::Ead::EadComponentParser.new
    @component.parse component_nokogiri_xml
    @component_title = @component.title
    @component_scope_content = @component.scope_content_value
    @component_html = @component.generate_html
    @flattened_component_structure = @component.generate_info
  end

  # @as_repo_id => repo ID in ArchiveSpace
  def validate_repository_code_and_set_repo_id
    unless REPOS.key? params[:repository_id]
      # not currently displaying contents of flash, but may be useful
      # when redirect to other than root
      flash[:error] = 'Non-existent repo code in url'
      # for now, redirect to root. Change later
      redirect_to '/'
    end
    @as_repo_id = REPOS[params[:repository_id]][:as_repo_id]
  end
end
