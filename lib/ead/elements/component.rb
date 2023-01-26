# Following class describes the Encoded Archival Description (EAD) element:
# <archdesc> Archival Description
# EAD specs: https://www.loc.gov/ead/index.html
#
# It supplies class methods to access the following children:
# <accessrestrict> Conditions Governing Access
# <accruals> Accruals
# <altformavail> Alternative Form Available
# <did> Descriptive Identification
# <dsc> Description of Subordinate Components
require 'forwardable'
require 'ead/elements/archdesc_component_commonality'

module Ead
  module Elements
    class Component < ArchdescComponentCommonality
      extend Forwardable
      XPATH = {
        c: './xmlns:c',
        c_level_attribute_subseries: './xmlns:c[@level="subseries"]'
      }.freeze

      class << self
        # returns: Nokogiri::XML::NodeSet of <c>
        def c_node_set(input_element)
          input_element.xpath(XPATH[:c])
        end

        # returns: Nokogiri::XML::NodeSet of <c level="subseries">
        def c_level_attribute_subseries_node_set(input_element)
          input_element.xpath(XPATH[:c_level_attribute_subseries])
        end
      end

      def_delegators :did, :container_info_barcode, :container_info_strings, :digital_archival_objects, :physical_description_extents_string

      def reset!(nokogiri_element = nil)
        super
        @did = nil
      end

      def did
        @did ||= ::Ead::Elements::Did.new(::Ead::Elements::Component.did_node_set(nokogiri_element).first)
      end

      def unit_dates
        did.unitdate_node_set
      end

      def unit_title(html_transforms = false)
        first_title = did.unittitle_node_set.first
        html_transforms ? ArchiveSpace::Parsers::EadHelper.apply_ead_to_html_transforms(first_title)&.to_s : first_title
      end

      def child_components
        self.class.c_node_set(nokogiri_element).map { |child_element| Component.new(child_element)}
      end
    end
  end
end
