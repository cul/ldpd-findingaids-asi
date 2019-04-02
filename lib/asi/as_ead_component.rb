require 'net/http'

module Asi
  class AsEadComponent
    XPATH = {
      title: './xmlns:did/xmlns:unittitle',
      scope_content_value: './xmlns:scopecontent/xmlns:p'
    }

    attr_reader *XPATH.keys

    XPATH.keys.each do |attr|
      define_method :"debug_#{attr}" do
        "#{self.send(attr)} DEBUG: #{XPATH[attr]}"
      end
    end

    # Takes a Nokogiri::XML::Element (fcd1: verify this)
    # containing a <c lelvel="series"> element
    def parse(nokogiri_xml)
      @nokogiri_xml = nokogiri_xml
      @title = nokogiri_xml.xpath(XPATH[:title]).text
      @scope_content_value = nokogiri_xml.xpath(XPATH[:scope_content_value]).text
    end

    def generate_info
      @component_info = []
      generate_component_info(@nokigiri_xml)
      @component_info = generate_child_components_info(@nokogiri_xml)
    end

    def generate_child_components_info(component_arg, nesting_level = 0)
      nesting_level += nesting_level
      components = component_arg.xpath('./xmlns:c')
      return if components.empty?
      components.each do |component|
        generate_component_info(component)
        generate_child_components_info(component)
      end
    end

    def generate_component_info(component)
      title = component.xpath('./xmlns:did/xmlns:unittitle').text
      scope_content = component.xpath('./xmlns:scopecontent/xmlns:p').text
      current_first_container_type = component.xpath('./xmlns:did/xmlns:container').first['type'] unless
        component.xpath('./xmlns:did/xmlns:container').first.nil?
      current_first_container_value = component.xpath('./xmlns:did/xmlns:container').first.text unless
        component.xpath('./xmlns:did/xmlns:container').first.nil?
      container_nokogiri_elements = component.xpath('./xmlns:did/xmlns:container')
      container_info = container_nokogiri_elements.map do |container|
        container_type = container['type']
        container_value = container.text
        "#{container_type.capitalize} #{container_value}"
      end
    end

    def generate_html
      @checkbox_id = 0
      @last_container_type = ''
      @last_container_value = nil
      @html_out = ''
      generate_html_child_components(@nokogiri_xml)
    end

    def generate_html_child_components(component_arg)
      components = component_arg.xpath('./xmlns:c')
      return if components.empty?
      @html_out << '<hr style="margin-top:10px;margin-bottom:10px">'
      @html_out << '<div class="component_entry" style="margin-left:2em;">'
      # puts series_files.inspect
      components.each do |component|
        generate_html_component(component)
        generate_html_child_components(component)
      end
      @html_out << '</div>'
      @html_out << '<hr style="margin-top:10px;margin-bottom:10px">'
    end

    def checkbox_display(container_type, container_value)
      if (!container_type.nil? and
          !container_value.nil? and
          container_value != @last_container_value)
        @last_container_type = container_type
        @last_container_value = container_value
        @checkbox_id += 1
        @html_out <<
          '<input type="checkbox" name="' <<
          "checkbox_#{@checkbox_id}" <<
          '" value="' <<
          "#{container_value}" <<
          '" style="text-align:right;float:right;"' <<
          '">' <<
          '<label style="text-align:right;float:right;" for="' <<
          "checkbox_#{@checkbox_id}>" <<
          '">' <<
          "Request #{container_type} #{container_value}" <<
          '</label><br style="clear:both;">'
      end
    end

    def generate_html_component(component)
      title = component.xpath('./xmlns:did/xmlns:unittitle').text
      scope_content = component.xpath('./xmlns:scopecontent/xmlns:p').text
      current_first_container_type = component.xpath('./xmlns:did/xmlns:container').first['type'] unless
        component.xpath('./xmlns:did/xmlns:container').first.nil?
      current_first_container_value = component.xpath('./xmlns:did/xmlns:container').first.text unless
        component.xpath('./xmlns:did/xmlns:container').first.nil?
      container_nokogiri_elements = component.xpath('./xmlns:did/xmlns:container')
      container_info = container_nokogiri_elements.map do |container|
        container_type = container['type']
        container_value = container.text
        "#{container_type.capitalize} #{container_value}"
      end
      checkbox_display(current_first_container_type, current_first_container_value)
      @html_out << '<p style="margin:0">'
      @html_out << '<span style="text-align:left;">' << title << '</span>'
      @html_out << '<span style="text-align:right;float:right;">' << container_info.join(' ') << '</span>'
      @html_out << '</p>'
      @html_out << '<p style="margin:0">' << scope_content << '</p>' unless scope_content.blank?
    end
  end
end
