module ComponentsHelper
  def checkbox_display(component_title, component_id, container_info_string, container_info_barcode)
    checkbox_html_out = ''
    if (!container_info_string.nil? and
        # fcd1: when port code to master branch, check name of data member containing repo code
        # code that sets this has changed
        (@repository&.checkbox_per_unittitle or
         container_info_string != @last_container_info_string_seen)
       )
#        container_info_string != @last_container_info_string_seen)
      @last_container_info_string_seen = container_info_string
      @checkbox_id += 1
      checkbox_name = "checkbox_#{component_id}_#{@checkbox_id}"
      checkbox_value_part_1 = "#{component_id}#{CONFIG[:container_info_delimiter]}#{remove_tags_from_unittitle_string(component_title.gsub("\"","&quot;"))}#{CONFIG[:container_info_delimiter]}#{container_info_string}"
      checkbox_value_part_2 ="#{CONFIG[:container_info_delimiter]}#{container_info_barcode}" if container_info_barcode
      checkbox_value = "#{checkbox_value_part_1}#{checkbox_value_part_2}"
      checkbox_html_out =
        %Q(<input type="checkbox" name="#{checkbox_name}" value="#{checkbox_value}" class="aeon_checkbox">) <<
        %Q(<label class="aeon_checkbox_label" for="checkbox_#{@checkbox_id}">Request #{container_info_string}</label>) <<
        '<br style="clear:both;">'
    end
    checkbox_html_out
  end

  def remove_tags_from_unittitle_string(unittitle_string)
    # fcd1: for now, explicit strings. Later, can regex it
    unless unittitle_string.blank?
      unittitle_string.gsub!('<unittitle>','')
      unittitle_string.gsub!('</unittitle>','')
      unittitle_string.gsub!('<i>','')
      unittitle_string.gsub!('</i>','')
    end
    unittitle_string
  end

  # this method only removes the <unittitle></unittitle> tags.
  # Other desired tags, such as <i>, are not removed because they
  # are needed for the desired display effect
  def remove_unittitle_tags(input_string)
    # fcd1: for now, explicit strings. Later, can regex it
    unless input_string.blank?
      input_string.gsub!('<unittitle>','')
      input_string.gsub!('</unittitle>','')
    end
    input_string
  end
end
