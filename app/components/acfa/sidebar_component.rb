# frozen_string_literal: true

class Acfa::SidebarComponent < ViewComponent::Base
  attr_reader :finding_aid_id, :restricted_access

  def initialize(arch_desc_dsc:, arch_desc_misc:, preview_flag:, restricted_access:, finding_aid_id:, **_args)
    @arch_desc_dsc = arch_desc_dsc
    @arch_desc_misc = arch_desc_misc
    @preview_flag = preview_flag
    @restricted_access = restricted_access
    @finding_aid_id = finding_aid_id
  end

  def has_subjects?
    controller.instance_variable_get(:@genres_forms).present? || controller.instance_variable_get(:@subjects).present?
  end

  def series_titles_urls
    @arch_desc_dsc.series_compound_title_array.map.with_index do |series_title, index|
      [series_title, repository_finding_aid_component_path(id: index+1, finding_aid_id: @finding_aid_id)]
    end
  end

  def slug
    @slug ||= repository_finding_aid_path(id: finding_aid_id)
    @preview_flag ? "/preview#{@slug}" : @slug
  end

  def subseries_titles
    @arch_desc_dsc.subseries_compound_title_array_for_each_series_array
  end
end
