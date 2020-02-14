module ComponentsHelper
  def checkbox_display(component_title, component_id, container_info)
    checkbox_html_out = ''
    if (!container_info.nil? and
        container_info != @last_container_seen)
      @last_container_seen = container_info
      @checkbox_id += 1
      checkbox_html_out =
        '<input type="checkbox" name="' <<
        "checkbox_#{component_id}_#{@checkbox_id}" <<
        '" value="' <<
        "#{component_title}COMPONENTTITLECONTAINERINFO#{container_info}" <<
        '" style="text-align:right;float:right;"' <<
        '" class="aeon_checkbox"' <<
        '">' <<
        '<label style="text-align:right;float:right;padding-right:5px;" for="' <<
        "checkbox_#{@checkbox_id}>" <<
        '">' <<
        "Request #{container_info.sub(/\s*\[\S*\]\s*/,' ')}" <<
        '</label><br style="clear:both;">'
    end
    checkbox_html_out
  end
end
