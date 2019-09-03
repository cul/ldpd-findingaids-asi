# Following class describes the EAD element <did>
# (see https://www.loc.gov/ead/tglib/elements/did.html)
# and supplies class methods to retrieve child elements
# of the <did>
require 'archive_space/ead/ead_helper'

module Ead
  module Elements
    class Did
      include  ArchiveSpace::Ead::EadHelper

      XPATH = {
        abstract: './xmlns:abstract',
        langmaterial: './xmlns:langmaterial',
        origination_label_attribute_creator: './xmlns:origination[@label="creator"]',
        physdesc: './xmlns:physdesc',
        repository_corpname: './xmlns:repository/xmlns:corpname',
        unitdate: './xmlns:unitdate',
        unitid: './xmlns:unitid',
        unittitle: './xmlns:unittitle'
      }.freeze

      class << self
        # returns: array of Nokogiri::XML::Element instances for <abstract>
        def abstract_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:abstract])
        end

        # returns: array of Nokogiri::XML::Element instances for <langmaterial>
        def langmaterial_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:langmaterial])
        end

        # returns: array of Nokogiri::XML::Element instances for <origination label="creator">
        def origination_label_attribute_creator_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:origination_label_attribute_creator])
        end

        # returns: array of Nokogiri::XML::Element instances for <physdesc>
        def physdesc_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:physdesc])
        end

        # returns: array of Nokogiri::XML::Element instances for <repository><corpname>
        def repository_corpname_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:repository_corpname])
        end

        # returns: array of Nokogiri::XML::Element instances for <unitdate>
        def unitdate_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:unitdate])
        end

        # returns: array of Nokogiri::XML::Element instances for <unitid>
        def unitid_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:unitid])
        end

        # returns: array of Nokogiri::XML::Element instances for <unittitle>
        def unittitle_array(ead_element)
          ead_element.xpath(XPATH[:unittitle])
        end
      end
    end
  end
end
