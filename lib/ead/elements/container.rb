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
        def label_attribute(nokogiri_element)
          nokogiri_element.xpath(XPATH[:label_attribute]).first
        end

        def type_attribute(nokogiri_element)
          nokogiri_element.xpath(XPATH[:type_attribute]).first
        end
      end
    end
  end
end
