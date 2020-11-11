# Following class describes the EAD element <physdesc> Physical Description
# (https://www.loc.gov/ead/tglib/elements/physdesc.html)
# and supplies class methods to retrieve pertinent child elements

module Ead
  module Elements
    class Physdesc

      XPATH = {
        extent: './xmlns:extent',
        physfacet: './xmlns:physfacet'
      }.freeze

      class << self
        # returns: Nokogiri::XML::NodeSet of <extent>
        # <extent> Extent
        def extent_node_set(input_element)
          input_element.xpath(XPATH[:extent])
        end
        # returns: Nokogiri::XML::NodeSet of <physfacet>
        # <physfacet> Physical Facet
        def physfacet_node_set(input_element)
          input_element.xpath(XPATH[:physfacet])
        end
      end
    end
  end
end
