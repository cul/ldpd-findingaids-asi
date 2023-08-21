module Acfa::EadParsingController
  def names_for_archdesc(arch_desc_misc)
    (arch_desc_misc.control_access_corporate_name_values +
     arch_desc_misc.control_access_personal_name_values).sort
  end

  def places_for_archdesc(arch_desc_misc)
    arch_desc_misc.control_access_geographic_name_values&.sort
  end

  def subjects_for_archdesc(arch_desc_misc)
    (arch_desc_misc.control_access_occupation_values +
     arch_desc_misc.control_access_subject_values).sort
  end
end