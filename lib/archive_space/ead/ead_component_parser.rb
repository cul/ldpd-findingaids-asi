require 'net/http'

module ArchiveSpace
  module Ead
    class EadComponentParser
      XPATH = {
        title: './xmlns:did/xmlns:unittitle',
        scope_content_value: './xmlns:scopecontent/xmlns:p'
      }

      attr_reader *XPATH.keys
      attr_reader :nokogiri_xml

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
        # puts @nokogiri_xml.inspect
        @component_info = []
        generate_component_info(@nokogiri_xml)
        # @component_info = generate_child_components_info(@nokogiri_xml)
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
        title = component.xpath('./xmlns:did/xmlns:unittitle').text
        date = component.xpath('./xmlns:did/xmlns:unitdate').text
        level = component['level']
        scope_content = component.xpath('./xmlns:scopecontent/xmlns:p').text
        # current_first_container_type = component.xpath('./xmlns:did/xmlns:container').first['type'] unless
        # component.xpath('./xmlns:did/xmlns:container').first.nil?
        # current_first_container_value = component.xpath('./xmlns:did/xmlns:container').first.text unless
        # component.xpath('./xmlns:did/xmlns:container').first.nil?
        container_nokogiri_elements = component.xpath('./xmlns:did/xmlns:container')
        container_info = container_nokogiri_elements.map do |container|
          container_type = container['type']
          container_value = container.text
          "#{container_type.capitalize} #{container_value}"
        end
        @component_info.append [nesting_level, title, date, level, scope_content, container_info]
      end
    end
  end
end
