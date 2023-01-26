require 'forwardable'
# this class parses the pertinent child elements of the <c> element
require 'ead/elements/component'
require 'ead/elements/container'
require 'ead/elements/dao'
require 'ead/elements/did'
require 'ead/elements/dsc'
require 'archive_space/parsers/ead_helper'

module ArchiveSpace
  module Parsers
    class ComponentParser
      extend Forwardable

      LOCAL_ATTRIBUTES = [
        :series,
        :flattened_component_tree_structure
      ].freeze

      SERIES_ATTRIBUTES = [
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
        :container_info_barcode,
        :container_info_strings,
        :custodial_history_head,
        :custodial_history_values,
        :digital_archival_objects,
        :level_attribute,
        :other_descriptive_data_head,
        :other_descriptive_data_values,
        :other_finding_aid_head,
        :other_finding_aid_values,
        :physical_description_extents_string,
        :related_material_head,
        :related_material_values,
        :scope_and_content_head,
        :scope_and_content_values,
        :separated_material_head,
        :separated_material_values,
        :unit_dates,
        :unit_title
      ].freeze

      ATTRIBUTES = (LOCAL_ATTRIBUTES + SERIES_ATTRIBUTES).freeze
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
        related_material_values: :relatedmaterial_p_node_set,
        scope_and_content_values: :scopecontent_p_node_set,
        separated_material_values: :separatedmaterial_p_node_set
      }

      attr_reader *LOCAL_ATTRIBUTES
      def_delegators :@series, *SERIES_ATTRIBUTES


      # fcd1, 09/15/19: may not need/use compound_title_string for second and lower-level <c> elements
      # for second-level <c> elements and lower levels <c> elements, the <head> chidlren are not
      # displayed currently, so won't include them in the ComponentInfo Struct.
      class ComponentInfo
        extend Forwardable
        attr_accessor *ATTRIBUTES.reject { |attribute| "#{attribute}".ends_with? "head" } + [:component, :nesting_level]
        EAD_ELEMENT_COMPONENT_METHODS.each do |member, class_method|
          define_method member do
            component.send(member).map do |value|
              (ArchiveSpace::Parsers::EadHelper.apply_ead_to_html_transforms value).to_s
            end
          end
        end
        def_delegators :@component, :compound_title_string, :container_info_strings, :container_info_barcode,
                       :digital_archival_objects, :physical_description_extents_string, :level_attribute

        def initialize(component, nesting_level = 0)
          @component = component
          @nesting_level = nesting_level
        end

        # fcd1, 09/15/19: may not need/use compound_title_string for second and lower-level <c> elements
        # if so, can remove the following
        # fcd1, 09/15/19: Assume only one <unititle> element is expected. If more are encountered, return first one.
        def unit_title
          component.unit_title(true)
        end

        def unit_dates
          component.unit_dates.map(&:text)
        end

        def children
          component.child_components.map { |c| ComponentInfo.new(c, nesting_level + 1) }
        end
      end
      # returns a recursively-created array of nested array represent the tree structure of the
      # descendant <c> components -- a <c> can contain another <c> element which itself may contain
      # a nested <c> element and so on. The most efficient to process this nested information at
      # display time is to flatten out the tree structure.
      def generate_structure_containing_lower_level_components(root_component, _series_num)
        accumulator = []
        generate_children_components_info(root_component, accumulator)
        accumulator
      end

      def generate_children_components_info(component, accumulator, previous_nesting_level = 0)
        current_nesting_level = previous_nesting_level + 1
        component.child_components.each do |child_component|
          accumulator.append generate_child_component_info(child_component, current_nesting_level)
          generate_children_components_info(child_component, accumulator, current_nesting_level)
        end
      end

      def generate_child_component_info(component, nesting_level = 0)
        ComponentInfo.new(component, nesting_level)
      end

      def parse(nokogiri_xml_document, series_num)
        arch_desc_dsc = nokogiri_xml_document.xpath("/xmlns:ead/xmlns:archdesc/xmlns:dsc")
        @series = ::Ead::Elements::Dsc.new(arch_desc_dsc).series_component(series_num)
      end

      def parse_all(nokogiri_xml_document)
        arch_desc_dsc = nokogiri_xml_document.xpath("/xmlns:ead/xmlns:archdesc/xmlns:dsc")
        ::Ead::Elements::Dsc.new(arch_desc_dsc).series_components
      end

      def flattened_component_tree_structure
        @flattened_component_tree_structure ||= generate_structure_containing_lower_level_components(@series, series_num)
      end
    end
  end
end
