require 'net/http'

module Asi
  class AsEadComponent
    XPATH = {
      title: './xmlns:did/xmlns:unittitle',
      scope_content: './xmlns:scopecontent/xmlns:p'
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
      @scope_content = nokogiri_xml.xpath(XPATH[:scope_content]).text
    end

    def generate_html
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
        title = component.xpath('./xmlns:did/xmlns:unittitle').text
        container_number = component.xpath('./xmlns:did/xmlns:container').text
        scope_content = component.xpath('./xmlns:scopecontent/xmlns:p').text
        @html_out << '<p style="margin:0">'
        @html_out << '<span style="text-align:left;">' << title << '</span>'
        @html_out << '<span style="text-align:right;float:right;">' << container_number << '</span>'
        @html_out << '</p>'
        @html_out << '<p style="margin:0">' << scope_content << '</p>'
        generate_html_child_components(component)
      end
      @html_out << '</div>'
      @html_out << '<hr style="margin-top:10px;margin-bottom:10px">'
    end
  end
end
