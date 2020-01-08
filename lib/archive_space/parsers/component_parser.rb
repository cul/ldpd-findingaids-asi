# this class parses the pertinent child elements of the <c> element
require 'archive_space/ead/ead_helper'
require 'ead/elements/component'
require 'ead/elements/container'
require 'ead/elements/dao'
require 'ead/elements/did'
require 'ead/elements/dsc'

module ArchiveSpace
  module Parsers
    class ComponentParser
      include  ArchiveSpace::Ead::EadHelper

      ATTRIBUTES = [
#       :accruals_head,
#       :accruals_values,
        :acquisition_information_head,
        :acquisition_information_values,
        :alternative_form_available_head,
        :alternative_form_available_values,
        :arrangement_head,
        :arrangement_values,
        :biography_or_history_head,
        :biography_or_history_values,
        :compound_title_string,
        :conditions_governing_access_head,
        :conditions_governing_access_values,
        :conditions_governing_use_head,
        :conditions_governing_use_values,
        :container_info_strings,
        :custodial_history_head,
        :custodial_history_values,
        :digital_archival_objects,
        :flattened_component_tree_structure,
        :level_attribute,
        :other_descriptive_data_head,
        :other_descriptive_data_values,
        :other_finding_aid_head,
        :other_finding_aid_values,
#        :preferred_citation_head,
#        :preferred_citation_values,
#        :processing_information_head,
#        :processing_information_values,
        :physical_description_extents_string,
        :related_material_head,
        :related_material_values,
        :scope_and_content_head,
        :scope_and_content_values,
        :separated_material_head,
        :separated_material_values,
        :unit_dates,
        :unit_title
      ]

      # Following hash maps attributes in this class to the class
      # methods in Ead::Elements::Component used to set the attribute value.
      EAD_ELEMENT_COMPONENT_METHODS = {
        acquisition_information_values: :acqinfo_p_node_set,
        alternative_form_available_values: :altformavail_p_node_set,
        arrangement_values: :arrangement_p_node_set,
        biography_or_history_values: :bioghist_p_node_set,
        conditions_governing_access_values: :accessrestrict_p_node_set,
        conditions_governing_use_values: :userestrict_p_node_set,
        custodial_history_values: :custodhist_p_node_set,
        other_descriptive_data_values: :odd_p_node_set,
        other_finding_aid_values: :otherfindaid_p_node_set,
#        :preferred_citation_head,
#        :preferred_citation_values,
#        :processing_information_head,
#        :processing_information_values,
        related_material_values: :relatedmaterial_p_node_set,
        scope_and_content_values: :scopecontent_p_node_set,
        separated_material_values: :separatedmaterial_p_node_set
      }

      attr_reader *ATTRIBUTES

      DigitalArchivalObject = Struct.new(:href, :description)

      # fcd1, 09/15/19: may not need/use compound_title_string for second and lower-level <c> elements
      # for second-level <c> elements and lower levels <c> elements, the <head> chidlren are not
      # displayed currently, so won't include them in the ComponentInfo Struct.
      ComponentInfo = Struct.new(*ATTRIBUTES.reject { |attribute| "#{attribute}".ends_with? "head" } + [:nesting_level])

      # returns a recursively-created array of nested array represent the tree structure of the
      # descendant <c> components -- a <c> can contain another <c> element which itself may contain
      # a nested <c> element and so on. The most efficient to process this nested information at
      # display time is to flatten out the tree structure.
      def generate_structure_containing_lower_level_components(root_component, series_num)
        @flattened_component_tree_structure = []
        generate_children_components_info(root_component)
      end

      def generate_children_components_info(component, previous_nesting_level = 0)
        current_nesting_level = previous_nesting_level + 1
        child_components = ::Ead::Elements::Component.c_node_set(component)
        return if child_components.empty?
        child_components.each do |child_component|
          @flattened_component_tree_structure.append generate_child_component_info(child_component, current_nesting_level)
          generate_children_components_info(child_component, current_nesting_level)
        end
      end

      def generate_child_component_info(component, nesting_level = 0)
        component_info = ComponentInfo.new
        did = ::Ead::Elements::Component.did_node_set(component).first
        EAD_ELEMENT_COMPONENT_METHODS.each do |member, class_method|
          component_info[member] = ::Ead::Elements::Component.send(class_method,component).map do |value|
            (apply_ead_to_html_transforms value).to_s
          end
        end
        component_info.digital_archival_objects = []
        # first retrieve the <did> element, then get the <dao> elements from the <did>
        ::Ead::Elements::Did.dao_node_set(did).each do |dao|
          component_info.digital_archival_objects.append DigitalArchivalObject.new(::Ead::Elements::Dao.href_attribute_node_set(dao).text,
                                                                     ::Ead::Elements::Dao.daodesc_p_node_set(dao).text)
        end
        # fcd1, 09/15/19: may not need/use compound_title_string for second and lower-level <c> elements
        # if so, can remove the following
        component_info.compound_title_string = ArchiveSpace::Parsers::EadHelper.compound_title component
        # fcd1, 09/15/19: Assume only one <unititle> element is expected. If more are encountered, return first one.
        component_info.unit_title = ::Ead::Elements::Did.unittitle_node_set(did).first.text unless
          ::Ead::Elements::Did.unittitle_node_set(did).first.nil?
        # component_info.unit_dates = ::Ead::Elements::Did.unitdate_node_set(did).map(&:text)
        component_info.unit_dates = ::Ead::Elements::Did.unitdate_node_set(did)
        component_info.container_info_strings = ::Ead::Elements::Did.container_node_set(did).map do |container|
          # container_type = container['label'] || container['type']
          # Assumption: at least one of the 'label' or 'type' attribute is present.
          container_type = (::Ead::Elements::Container.label_attribute_node_set(container).first ||
                            ::Ead::Elements::Container.type_attribute_node_set(container).first).text
          container_value = container.text
          "#{container_type.titlecase} #{container_value}"
        end
        component_info.nesting_level = nesting_level
        physical_descriptions = ::Ead::Elements::Did.physdesc_node_set(did)
        component_info.physical_description_extents_string =
          ArchiveSpace::Parsers::EadHelper.compound_physical_descriptions_into_string physical_descriptions
        component_info.level_attribute = ::Ead::Elements::Component.level_attribute_node_set(component).first.text unless
          ::Ead::Elements::Component.level_attribute_node_set(component).empty?
        component_info
      end

      def generate_component_info_legacy_copy(component, nesting_level = 0)
        component_notes = ComponentInfo.new
        title = component.xpath(XPATH[:title]).text
        physical_description = component.xpath(XPATH[:physical_description]).text
        dates = component.xpath(XPATH[:dates])
        digital_archival_objects_description_href =
          component.xpath(XPATH[:digital_archival_objects]).map do |dao|
          [dao.xpath(XPATH[:digital_archival_object_description_p]).text, dao.attribute('href').text]
        end
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
                                 dates,
                                 digital_archival_objects_description_href,
                                 level,
                                 container_info,
                                 component_notes
                               ]

      end

      def parse(nokogiri_xml_document, series_num)
        arch_desc_dsc = nokogiri_xml_document.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc')
        series = ::Ead::Elements::Dsc.c_level_attribute_series_array(arch_desc_dsc)[series_num -1]
        did = ::Ead::Elements::Component.did_node_set(series).first
        # puts series.inspect
#        @accruals_head = ::Ead::Elements::Component.accruals_head_array(series).first.text unless
#          ::Ead::Elements::Component.accruals_head_array(series).empty?
#        @accruals_values = ::Ead::Elements::Component.accruals_p_array(series)
        @acquisition_information_head = ::Ead::Elements::Component.acqinfo_head_node_set(series).first.text unless
          ::Ead::Elements::Component.acqinfo_head_node_set(series).empty?
        @acquisition_information_values = ::Ead::Elements::Component.acqinfo_p_node_set(series)
        @alternative_form_available_head = ::Ead::Elements::Component.altformavail_head_node_set(series).first.text unless
          ::Ead::Elements::Component.altformavail_head_node_set(series).empty?
        @alternative_form_available_values = ::Ead::Elements::Component.altformavail_p_node_set(series)
        @arrangement_head = ::Ead::Elements::Component.arrangement_head_node_set(series).first.text unless
          ::Ead::Elements::Component.arrangement_head_node_set(series).empty?
        @arrangement_values = ::Ead::Elements::Component.arrangement_p_node_set(series)
        @biography_or_history_head = ::Ead::Elements::Component.bioghist_head_node_set(series).first.text unless
          ::Ead::Elements::Component.bioghist_head_node_set(series).empty?
        @biography_or_history_values = ::Ead::Elements::Component.bioghist_p_node_set(series)
        @compound_title_string = ArchiveSpace::Parsers::EadHelper.compound_title series
        @conditions_governing_access_head = ::Ead::Elements::Component.accessrestrict_head_node_set(series).first.text unless
          ::Ead::Elements::Component.accessrestrict_head_node_set(series).empty?
        @conditions_governing_access_values = ::Ead::Elements::Component.accessrestrict_p_node_set(series)
        @conditions_governing_use_head = ::Ead::Elements::Component.userestrict_head_node_set(series).first.text unless
          ::Ead::Elements::Component.userestrict_head_node_set(series).empty?
        @conditions_governing_use_values = ::Ead::Elements::Component.userestrict_p_node_set(series)
        @container_info_strings = ::Ead::Elements::Did.container_node_set(did).map do |container|
          # container_type = container['label'] || container['type']
          # Assumption: at least one of the 'label' or 'type' attribute is present.
          container_type = (::Ead::Elements::Container.label_attribute_node_set(container).first ||
                            ::Ead::Elements::Container.type_attribute_node_set(container).first).text
          container_value = container.text
          "#{container_type.titlecase} #{container_value}"
        end
        @custodial_history_head = ::Ead::Elements::Component.custodhist_head_node_set(series).first.text unless
          ::Ead::Elements::Component.custodhist_head_node_set(series).empty?
        @custodial_history_values = ::Ead::Elements::Component.custodhist_p_node_set(series)
        @digital_archival_objects = []
        # first retrieve the <did> element, then get the <dao> elements from the <did>
        ::Ead::Elements::Did.dao_node_set(did).each do |dao|
          @digital_archival_objects.append DigitalArchivalObject.new(::Ead::Elements::Dao.href_attribute_node_set(dao).text,
                                                                     ::Ead::Elements::Dao.daodesc_p_node_set(dao).text)
        end
        @level_attribute = ::Ead::Elements::Component.level_attribute_node_set(series).first.text unless
          ::Ead::Elements::Component.level_attribute_node_set(series).empty?
        @other_descriptive_data_head = ::Ead::Elements::Component.odd_head_node_set(series).first.text unless
          ::Ead::Elements::Component.odd_head_node_set(series).empty?
        @other_descriptive_data_values = ::Ead::Elements::Component.odd_p_node_set(series)
        @other_finding_aid_head = ::Ead::Elements::Component.otherfindaid_head_node_set(series).first.text unless
          ::Ead::Elements::Component.otherfindaid_head_node_set(series).empty?
        @other_finding_aid_values = ::Ead::Elements::Component.otherfindaid_p_node_set(series)
#        @preferred_citation_head = ::Ead::Elements::Component.prefercite_head_array(series).first.text unless
#          ::Ead::Elements::Component.prefercite_head_array(series).empty?
#        @preferred_citation_values = ::Ead::Elements::Component.prefercite_p_array(series)
#        @processing_information_head = ::Ead::Elements::Component.processinfo_head_array(series).first.text unless
#          ::Ead::Elements::Component.processinfo_head_array(series).empty?
#        @processing_information_values = ::Ead::Elements::Component.processinfo_p_array(series)
        @related_material_head = ::Ead::Elements::Component.relatedmaterial_head_node_set(series).first.text unless
          ::Ead::Elements::Component.relatedmaterial_head_node_set(series).empty?
        @related_material_values = ::Ead::Elements::Component.relatedmaterial_p_node_set(series)
        @scope_and_content_head = ::Ead::Elements::Component.scopecontent_head_node_set(series).first.text unless
          ::Ead::Elements::Component.scopecontent_head_node_set(series).empty?
        @scope_and_content_values = ::Ead::Elements::Component.scopecontent_p_node_set(series)
        @separated_material_head = ::Ead::Elements::Component.separatedmaterial_head_node_set(series).first.text unless
          ::Ead::Elements::Component.separatedmaterial_head_node_set(series).empty?
        @separated_material_values = ::Ead::Elements::Component.separatedmaterial_p_node_set(series)
        # Assume AS EAD <did>s will only contain one <unittitle>
        @unit_dates = ::Ead::Elements::Did.unitdate_node_set(did)
        @unit_title = ::Ead::Elements::Did.unittitle_node_set(did).first
        physical_descriptions = ::Ead::Elements::Did.physdesc_node_set(did)
        @physical_description_extents_string =
          ArchiveSpace::Parsers::EadHelper.compound_physical_descriptions_into_string physical_descriptions
        generate_structure_containing_lower_level_components(series, series_num)
      end

      # legacy component struture methods
      def generate_info_legacy
        @component_info = []
        # generate_component_info(@nokogiri_xml)
        generate_child_components_info(@nokogiri_xml)
        @component_info
      end

      def generate_child_components_info_legacy(component_arg, nesting_level = 0)
        nesting_level += 1
        components = component_arg.xpath('./xmlns:c')
        return if components.empty?
        components.each do |component|
          generate_component_info(component, nesting_level)
          generate_child_components_info(component, nesting_level)
        end
      end

      def generate_component_info_legacy(component, nesting_level = 0)
        component_notes = ComponentInfo.new
        title = component.xpath(XPATH[:title]).text
        physical_description = component.xpath(XPATH[:physical_description]).text
        dates = component.xpath(XPATH[:dates])
        digital_archival_objects_description_href =
          component.xpath(XPATH[:digital_archival_objects]).map do |dao|
          [dao.xpath(XPATH[:digital_archival_object_description_p]).text, dao.attribute('href').text]
        end
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
                                 dates,
                                 digital_archival_objects_description_href,
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

      # fcd1, 09/02/19: NEED TO RETHNK/REIMPLEMENT THIS
      def series_scope_content_values
        series_nokogiri_elements =
          @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]')
        series_scope_content = series_nokogiri_elements.map do |series|
          series.xpath('./xmlns:scopecontent/xmlns:p')
        end
      end

      # fcd1, 09/02/19: NEED TO RETHNK/REIMPLEMENT THIS
      # fcd1, 03/11/19: Continure refactoring following when time allows
      # Note: arg start from 1, but array start at index 0
      def get_files_info_for_series(i)
        series_file_info_nokogiri_elements =
          @dsc_series[i.to_i - 1].xpath('./xmlns:c[@level="file"]')
        series_files_info = series_file_info_nokogiri_elements.map do |file_info_nokogiri_element|
          title = file_info_nokogiri_element.xpath('./xmlns:did/xmlns:unittitle').text
          box_number = file_info_nokogiri_element.xpath('./xmlns:did/xmlns:container').text
          {title: title, box_number: box_number}
        end
      end
    end
  end
end
