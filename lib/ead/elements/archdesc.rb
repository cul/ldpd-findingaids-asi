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
    class Archdesc < ArchdescComponentCommonality
      XPATH = {
      }.freeze

      class << self
      end
    end
  end
end
