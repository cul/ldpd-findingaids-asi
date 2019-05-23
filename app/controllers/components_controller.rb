require 'archive_space/api/client'
require 'archive_space/ead/ead_parser'
require 'archive_space/ead/ead_component_parser'

class ComponentsController < ApplicationController
  before_action :set_bib_id,
                :validate_repository_code_and_set_repo_id,
                :validate_bib_id_and_set_resource_id

  def index
    if CONFIG[:use_fixtures]
      @input_xml =
        @as_api.get_ead_resource_description_from_local_fixture(@as_repo_id,@as_resource_id)
    else
      @input_xml = @as_api.get_ead_resource_description(@as_repo_id,@as_resource_id)
    end
    @ead = ArchiveSpace::Ead::EadParser.new @input_xml
    @finding_aid_title =
      [@ead.unit_title, @ead.compound_dates_into_string(@ead.unit_dates)].join(', ')
    @series_titles = @ead.dsc_series_titles
    @flattened_component_structure_array = []
    @series_titles.each_with_index do |title, index|
      ead_series_set_properties(index + 1)
      @flattened_component_structure_array.append @flattened_component_structure
    end
  end

  def show
    if CONFIG[:use_fixtures]
      @input_xml =
        @as_api.get_ead_resource_description_from_local_fixture(@as_repo_id,@as_resource_id)
    else
      @input_xml = @as_api.get_ead_resource_description(@as_repo_id,@as_resource_id)
    end
    @ead = ArchiveSpace::Ead::EadParser.new @input_xml
    @finding_aid_title =
      [@ead.unit_title, @ead.compound_dates_into_string(@ead.unit_dates)].join(', ')
    @series_titles = @ead.dsc_series_titles
    ead_series_set_properties params[:id]
  end

  private
  def ead_series_set_properties component_num
    component_nokogiri_xml = @ead.dsc_series[component_num.to_i - 1]
    @component = ArchiveSpace::Ead::EadComponentParser.new
    @component.parse component_nokogiri_xml
    @access_restrictions_ps = @component.access_restrictions_ps
    @arrangement_ps = @component.arrangement_ps
    @component_title = @component.title
    @other_finding_aid_ps = @component.other_finding_aid_ps
    @separated_material_ps = @component.separated_material_ps
    @component_scope_content_ps = @component.scope_content_ps
    @flattened_component_structure = @component.generate_info
  end

  def set_bib_id
    @bib_id = params[:finding_aid_id].delete_prefix('ldpd_').to_i
  end
end
