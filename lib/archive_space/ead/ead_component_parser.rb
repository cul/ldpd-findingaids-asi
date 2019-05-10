require 'net/http'

module ArchiveSpace
  module Ead
    class EadComponentParser
      XPATH = {
        container: './xmlns:did/xmlns:container',
        date: './xmlns:did/xmlns:unitdate',
        other_finding_aid_value: './xmlns:otherfindaid/xmlns:p',
        title: './xmlns:did/xmlns:unittitle',
        scope_content_p: './xmlns:scopecontent/xmlns:p'
      }

      attr_reader *XPATH.keys
      attr_reader :nokogiri_xml
      attr_reader :scope_content_value

      # Takes a Nokogiri::XML::Element (fcd1: verify this)
      # containing a <c lelvel="series"> element
      def parse(nokogiri_xml)
        @nokogiri_xml = nokogiri_xml
        @title = nokogiri_xml.xpath(XPATH[:title]).text
        @scope_content_value = nokogiri_xml.xpath(XPATH[:scope_content_p]).text
      end

      def generate_info
        @component_info = []
        generate_component_info(@nokogiri_xml)
        generate_child_components_info(@nokogiri_xml)
        @component_info
      end

      def generate_child_components_info(component_arg, nesting_level = 0)
        nesting_level += 1
        components = component_arg.xpath('./xmlns:c')
        return if components.empty?
        components.each do |component|
          generate_component_info(component, nesting_level)
          generate_child_components_info(component, nesting_level)
        end
      end

      def generate_component_info(component, nesting_level = 0)
        title = component.xpath(XPATH[:title]).text
        date = component.xpath(XPATH[:date]).text
        level = component.attribute('level').text
        scope_content_values = component.xpath(XPATH[:scope_content_p])
        other_finding_aid = component.xpath(XPATH[:other_finding_aid_value]).text
        container_nokogiri_elements = component.xpath(XPATH[:container])
        container_info = container_nokogiri_elements.map do |container|
          container_type = container['type']
          container_value = container.text
          "#{container_type.capitalize} #{container_value}"
        end
        @component_info.append [nesting_level, title, date, level, scope_content_values, other_finding_aid, container_info]
      end
    end
  end
end
