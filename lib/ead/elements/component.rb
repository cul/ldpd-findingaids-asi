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
require 'ead/elements/archdesc_component_commonality'

module Ead
  module Elements
    class Component < ArchdescComponentCommonality
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
    end
  end
end
