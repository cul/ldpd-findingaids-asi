# Following class describes the EAD element <did>
# Descriptive Identification (https://www.loc.gov/ead/tglib/elements/did.html)
# and supplies class methods to retrieve pertinent child elements
# of the <did> element
require 'archive_space/ead/ead_helper'

module Ead
  module Elements
    class Did

      XPATH = {
        abstract: './xmlns:abstract',
        container: './xmlns:container',
        dao: './xmlns:dao',
        langmaterial: './xmlns:langmaterial',
        origination_label_attribute_creator: './xmlns:origination[@label="Creator"]',
        physdesc: './xmlns:physdesc',
        repository_corpname: './xmlns:repository/xmlns:corpname',
        unitdate: './xmlns:unitdate',
        unitid: './xmlns:unitid',
        unittitle: './xmlns:unittitle'
      }.freeze

      class << self
        # returns: array of Nokogiri::XML::Element instances for <abstract>
        def abstract_node_set(nokogiri_element)
          nokogiri_element.xpath(XPATH[:abstract])
        end

        def container_node_set(nokogiri_element)
          nokogiri_element.xpath(XPATH[:container])
        end

        # argument: Nokogiri::XML::Element representing a <did> element
        # returns: Nokogiri::XML::NodeSet of <dao> elements
        def dao_node_set(nokogiri_xml_element)
          nokogiri_xml_element.xpath(XPATH[:dao])
        end

        # returns: array of Nokogiri::XML::Element instances for <langmaterial>
        def langmaterial_node_set(nokogiri_element)
          nokogiri_element.xpath(XPATH[:langmaterial])
        end

        # returns: array of Nokogiri::XML::Element instances for <origination label="creator">
        def origination_label_attribute_creator_node_set(nokogiri_element)
          nokogiri_element.xpath(XPATH[:origination_label_attribute_creator])
        end

        # returns: array of Nokogiri::XML::Element instances for <physdesc>
        def physdesc_node_set(nokogiri_element)
          nokogiri_element.xpath(XPATH[:physdesc])
        end

        # returns: array of Nokogiri::XML::Element instances for <repository><corpname>
        def repository_corpname_node_set(nokogiri_element)
          nokogiri_element.xpath(XPATH[:repository_corpname])
        end

        # returns: array of Nokogiri::XML::Element instances for <unitdate>
        def unitdate_node_set(nokogiri_element)
          nokogiri_element.xpath(XPATH[:unitdate])
        end

        # returns: array of Nokogiri::XML::Element instances for <unitid>
        def unitid_node_set(nokogiri_element)
          nokogiri_element.xpath(XPATH[:unitid])
        end

        # returns: array of Nokogiri::XML::Element instances for <unittitle>
        def unittitle_node_set(ead_element)
          ead_element.xpath(XPATH[:unittitle])
        end
      end
    end
  end
end
