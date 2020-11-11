# Following class describes the EAD element <extent>
# (see https://www.loc.gov/ead/tglib/elements/extent.html)
# and supplies class method to retrieve pertinent attribute
# of the <extent> element

module Ead
  module Elements
    class Extent
      XPATH = {
        altrender_attribute: './@altrender'
      }.freeze
      class << self
        def altrender_attribute_node_set(input_element)
          input_element.xpath(XPATH[:altrender_attribute])
        end
      end
    end
  end
end
