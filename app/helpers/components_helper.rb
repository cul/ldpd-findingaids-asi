module ComponentsHelper
  def checkbox_display(component_title, component_id, container_info_string, container_info_barcode)
    checkbox_html_out = ''
    if (!container_info_string.nil? and
        # fcd1: when port code to master branch, check name of data member containing repo code
        # code that sets this has changed
        (REPOS[@repository_code][:checkbox_per_unittitle] or
         container_info_string != @last_container_info_string_seen)
       )
#        container_info_string != @last_container_info_string_seen)
      @last_container_info_string_seen = container_info_string
      @checkbox_id += 1
      checkbox_value_part_1 = "#{remove_tags_unittitle(component_title.gsub("\"","&quot;"))}#{CONFIG[:container_info_delimiter]}#{container_info_string}"
      checkbox_value_part_2 ="#{CONFIG[:container_info_delimiter]}#{container_info_barcode}" if container_info_barcode
      checkbox_html_out =
        '<input type="checkbox" name="' <<
        "checkbox_#{component_id}_#{@checkbox_id}" <<
        '" value="' <<
        "#{checkbox_value_part_1}#{checkbox_value_part_2}" <<
        '" style="text-align:right;float:right;"' <<
        '" class="aeon_checkbox"' <<
        '">' <<
        '<label style="text-align:right;float:right;padding-right:5px;" for="' <<
        "checkbox_#{@checkbox_id}>" <<
        '">' <<
        "Request #{container_info_string}" <<
        '</label><br style="clear:both;">'
    end
    checkbox_html_out
  end

  def remove_tags_unittitle(unittitle_string)
    # fcd1: for now, explicit strings. Later, can regex it
    unless unittitle_string.blank?
      unittitle_string.gsub!('<unittitle>','')
      unittitle_string.gsub!('</unittitle>','')
      unittitle_string.gsub!('<i>','')
      unittitle_string.gsub!('</i>','')
    end
    unittitle_string
  end
end
