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
        c: './xmlns:c'
      }.freeze

      class << self
        # returns: array of Nokogiri::XML::Element instances of <c>
        def c_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:c])
        end
      end
    end
  end
end
