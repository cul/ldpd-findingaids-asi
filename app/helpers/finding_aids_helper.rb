module FindingAidsHelper
  def on_finding_aids_root?
    controller_name == 'repositories' && action_name == 'index'
  end

  # the Repositories menu item is only active on the Repositories index page
  def finding_aids_active_class
    'active' if on_finding_aids_root?
  end

  def has_control_access_terms?
    @subjects.present? || @genres_forms.present? || @name_terms.present? || @place_terms.present?
  end
end
