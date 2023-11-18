# frozen_string_literal: true

class Acfa::AeonWrapperComponent < Acfa::SeriesCollectionComponent
  def arch_desc_did
    @arch_desc_did ||= controller.instance_variable_get(:@arch_desc_did)
  end

  def arch_desc_dsc
    @arch_desc_dsc ||= controller.instance_variable_get(:@arch_desc_dsc)
  end

  def authenticity_token
    @authenticity_token ||= controller.instance_variable_get(:@authenticity_token)
  end

  def component_title
    @component_title ||= controller.instance_variable_get(:@component_title)
  end

  def finding_aid_title
    @finding_aid_title ||= controller.instance_variable_get(:@finding_aid_title)
  end

  def restricted_access_flag
    @restricted_access_flag ||= controller.instance_variable_get(:@restricted_access_flag)
  end

  def series_titles
    arch_desc_dsc.series_compound_title_array
  end

  def unprocessed_flag
    @unprocessed_flag ||= controller.instance_variable_get(:@unprocessed_flag)
  end

  def user_review_value
    @user_review_value ||= controller.instance_variable_get(:@user_review_value)
  end
end
