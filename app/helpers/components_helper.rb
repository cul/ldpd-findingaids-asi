module ComponentsHelper
  def display_component_structure
    @html_out = '<p><i>Following html generate by ComponentsHelper#display_component_structure</i></p>'
    @last_container_seen = ''
    @checkbox_id = 0
    # nesting level starts at 1 (top-level)
    current_nesting_level = 1
    @flattened_component_structure.each do |component|
      nesting_level, title, scope_content, container_info = component
      if nesting_level > current_nesting_level
        @html_out << '<hr style="margin-top:10px;margin-bottom:10px">'
        @html_out << '<div class="component_entry" style="margin-left:2em;">'
      elsif nesting_level < current_nesting_level
        @html_out << '<hr style="margin-top:10px;margin-bottom:10px">'
        @html_out << '</div>'
      end
      current_nesting_level = component[0]
      checkbox_display(container_info[0]) unless container_info.empty?
      @html_out << '<p style="margin:0">'
      @html_out << '<span style="text-align:left;">' << title << '</span>'
      @html_out << '<span style="text-align:right;float:right;">' << container_info.join(' ') << '</span>'
      @html_out << '</p>'
      @html_out << '<p style="margin:0">' << scope_content << '</p>' unless scope_content.blank?
    end
    @html_out
  end
end
