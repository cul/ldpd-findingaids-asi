module ComponentsHelper
  def checkbox_display(component_title, container_info)
    checkbox_html_out = ''
    if (!container_info.nil? and
        container_info != @last_container_seen)
      @last_container_seen = container_info
      @checkbox_id += 1
      checkbox_html_out =
        '<input type="checkbox" name="' <<
        "checkbox_#{@checkbox_id}" <<
        '" value="' <<
        "#{component_title}COMPONENTTITLECONTAINERINFO#{container_info}" <<
        '" style="text-align:right;float:right;"' <<
        '">' <<
        '<label style="text-align:right;float:right;" for="' <<
        "checkbox_#{@checkbox_id}>" <<
        '">' <<
        "Request #{container_info}" <<
        '</label><br style="clear:both;">'
    end
    checkbox_html_out
  end
end
