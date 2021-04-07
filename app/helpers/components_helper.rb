module ComponentsHelper
  def checkbox_display(component_title, component_id, container_info_string, container_info_barcode)
    checkbox_html_out = ''
    if (!container_info_string.nil? and
        container_info_string != @last_container_info_string_seen)
      @last_container_info_string_seen = container_info_string
      @checkbox_id += 1
      checkbox_value_part_1 = "#{component_title.gsub("\"","&quot;")}#{CONFIG[:container_info_delimiter]}#{container_info_string}"
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
end
