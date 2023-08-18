module Acfa::EadParsingController
  def subjects_for_archdesc(arch_desc_misc)
    (arch_desc_misc.control_access_corporate_name_values +
     arch_desc_misc.control_access_geographic_name_values +
     arch_desc_misc.control_access_occupation_values +
     arch_desc_misc.control_access_personal_name_values +
     arch_desc_misc.control_access_subject_values).sort
  end
end