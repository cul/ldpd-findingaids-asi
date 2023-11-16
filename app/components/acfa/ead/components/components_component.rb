# frozen_string_literal: true

module Acfa::Ead::Components
  class ComponentsComponent < Blacklight::Component
    attr_reader :component_info, :component_id, :parser, :element, :nesting_level, :repository

    delegate :checkbox_display, :remove_unittitle_tags, to: :helpers

    def initialize(component_info:, parser:, element:, repository:, nesting_level:, aeon_enabled: false, component_id: nil)
      @component_info = component_info
      @aeon_enabled = aeon_enabled
      @component_id = component_id
      @repository = repository
      @element = element
      @parser = parser
      @nesting_level = nesting_level
    end

    def aeon_enabled?
      @aeon_enabled
    end

    def child_component_elements
      @child_component_elements = ::Ead::Elements::Component.c_node_set(element) || []
    end

    def each_child_component &block
      child_nesting_level = nesting_level + 1
      child_component_elements.each do |child_element|
        block.yield [child_element, parser.generate_child_component_info(child_element, child_nesting_level), child_nesting_level]
      end
    end

    def conditions_governing_access_values
      @conditions_governing_access_values ||= (component_info.conditions_governing_access_values || [])
    end

    def conditions_governing_use_values
      @conditions_governing_use_values ||= (component_info.conditions_governing_use_values || [])
    end

    def digital_archival_objects
      @digital_archival_objects ||= (component_info.digital_archival_objects || [])
    end

    def misc_notes
      @misc_notes ||= component_info.scope_and_content_values +
        component_info.arrangement_values +
        component_info.related_material_values +
        component_info.separated_material_values +
        component_info.alternative_form_available_values +
        component_info.biography_or_history_values +
        component_info.custodial_history_values +
        component_info.acquisition_information_values +
        component_info.other_descriptive_data_values +
        component_info.other_finding_aid_values
    end
  end
end
