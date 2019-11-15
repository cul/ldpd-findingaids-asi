# Following class describes the EAD element <dao>
# Digital Archival Object (https://www.loc.gov/ead/tglib/elements/dao.html)
# and supplies class methods to retrieve pertinent attributes and
# child elements of the <dao> element

# Notation note: <a><b> means <b> elements that are direct children of <a>
module Ead
  module Elements
    class Dao

      XPATH = {
        daodesc_p: './xmlns:daodesc/xmlns:p',
        href_attribute: './@xlink:href'
      }.freeze

      class << self
        # argument: Nokogiri::XML::Element representing a <dao> element
        # returns: Nokogiri::XML::NodeSet of <daodesc><p>
        # <daodesc> Digital Archival Object Description
        def daodesc_p_node_set(nokogiri_xml_element)
          nokogiri_xml_element.xpath(XPATH[:daodesc_p])
        end

        # argument: Nokogiri::XML::Element representing a <dao> element
        # returns: Nokogiri::XML::NodeSet containing href attribute of <dao> element
        # href -- The locator for a remote resource in a simple or extended link
        def href_attribute_node_set(nokogiri_xml_element)
          nokogiri_xml_element.xpath(XPATH[:href_attribute])
        end
      end
    end
  end
end
