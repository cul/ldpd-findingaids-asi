# Following class describes the EAD element <container>
# (see https://www.loc.gov/ead/tglib/elements/container.html)
# and supplies class methods to retrieve pertinent child elements
# of the <container>

module Ead
  module Elements
    class Container

      XPATH = {
        label_attribute: './@label',
        type_attribute: './@type'
      }.freeze

      class << self
        def label_attribute_node_set(input_element)
          input_element.xpath(XPATH[:label_attribute])
        end

        def type_attribute_node_set(input_element)
          input_element.xpath(XPATH[:type_attribute])
        end
      end
    end
  end
end
