require 'archive_space/ead/ead_helper'

module ArchiveSpace
  module Ead
    class EadComponentParser
      include  ArchiveSpace::Ead::EadHelper

      XPATH = {
        access_restrictions_ps: './xmlns:accessrestrict/xmlns:p',
        acquisition_information_ps: './xmlns:acqinfo/xmlns:p',
        alternative_form_available_ps: './xmlns:altformavail/xmlns:p',
        arrangement_ps: './xmlns:arrangement/xmlns:p',
        biography_history_ps: './xmlns:bioghist/xmlns:p',
        container: './xmlns:did/xmlns:container',
        custodial_history_ps: './xmlns:custodhist/xmlns:p',
        date: './xmlns:did/xmlns:unitdate',
        digital_archival_object: './xmlns:did/xmlns:doa',
        odd_ps: './xmlns:odd/xmlns:p',
        other_finding_aid_ps: './xmlns:otherfindaid/xmlns:p',
        physical_description: './xmlns:did/xmlns:physdesc',
        related_material_ps: './xmlns:relatedmaterial/xmlns:p',
        scope_content_ps: './xmlns:scopecontent/xmlns:p',
        separated_material_ps: './xmlns:separatedmaterial/xmlns:p',
        title: './xmlns:did/xmlns:unittitle',
        use_restrictions_ps: './xmlns:userestrict/xmlns:p'
      }

      COMPONENT_INFO_MEMBERS = XPATH.keys - [:container, :date, :physical_description, :title]
      ComponentInfo = Struct.new(*COMPONENT_INFO_MEMBERS)

      attr_reader *XPATH.keys
      attr_reader :nokogiri_xml, :notes

      # Takes a Nokogiri::XML::Element (fcd1: verify this)
      # containing a <c lelvel="series"> element
      def parse(nokogiri_xml)
        @nokogiri_xml = nokogiri_xml
        @notes = ComponentInfo.new
        COMPONENT_INFO_MEMBERS.each do |member|
          @notes[member] = nokogiri_xml.xpath(XPATH[member])
        end
        @title = nokogiri_xml.xpath(XPATH[:title]).text
      end

      def generate_info
        @component_info = []
        # generate_component_info(@nokogiri_xml)
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
        component_notes = ComponentInfo.new
        title = component.xpath(XPATH[:title]).text
        physical_description = component.xpath(XPATH[:physical_description]).text
        date = component.xpath(XPATH[:date]).text
        level = component.attribute('level').text
        container_nokogiri_elements = component.xpath(XPATH[:container])
        container_info = container_nokogiri_elements.map do |container|
          container_type = container['label'] || container['type']
          container_value = container.text
          "#{container_type.titlecase} #{container_value}"
        end
        COMPONENT_INFO_MEMBERS.each do |member|
          component_notes[member] = component.xpath(XPATH[member]).map do |content|
          (apply_ead_to_html_transforms content).to_s
          end
        end
        @component_info.append [ nesting_level,
                                 title,
                                 physical_description,
                                 date,
                                 level,
                                 container_info,
                                 component_notes
                               ]

      end

      def generate_component_info_old(component, nesting_level = 0)
        title = component.xpath(XPATH[:title]).text
        physical_description = component.xpath(XPATH[:physical_description]).text
        date = component.xpath(XPATH[:date]).text
        level = component.attribute('level').text
        access_restrictions_ps = component.xpath(XPATH[:access_restrictions_ps]).map do |access_restrictions_p|
          (apply_ead_to_html_transforms access_restrictions_p).to_s
        end
        scope_content_ps = component.xpath(XPATH[:scope_content_ps]).map do |scope_content_p|
          (apply_ead_to_html_transforms scope_content_p).to_s
        end
        separated_material_ps = component.xpath(XPATH[:separated_material_ps]).map do |separated_material_p|
          (apply_ead_to_html_transforms separated_material_p).to_s
        end
        other_finding_aid_ps = component.xpath(XPATH[:other_finding_aid_ps]).map do |other_finding_aid_p|
          (apply_ead_to_html_transforms other_finding_aid_p).to_s
        end
        container_nokogiri_elements = component.xpath(XPATH[:container])
        container_info = container_nokogiri_elements.map do |container|
          container_type = container['label'] || container['type']
          container_value = container.text
          "#{container_type.titlecase} #{container_value}"
        end
        @component_info.append [ nesting_level,
                                 title,
                                 physical_description,
                                 date,
                                 level,
                                 access_restrictions_ps,
                                 scope_content_ps,
                                 separated_material_ps,
                                 other_finding_aid_ps,
                                 container_info ]
      end
    end
  end
end
