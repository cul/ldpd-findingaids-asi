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
        origination: './xmlns:origination',
        physdesc_extent: './xmlns:physdesc/xmlns:extent',
        unitdate: './xmlns:unitdate',
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

        # returns: array of Nokogiri::XML::Element instances for <origination>
        def origination_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:origination])
        end

        # returns: array of Nokogiri::XML::Element instances for <physdesc>
        def physdesc_extent_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:physdesc_extent])
        end

        # returns: array of Nokogiri::XML::Element instances for <unitdate>
        def unitdate_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:unitdate])
        end

        # returns: Nokogiri::XML::Element instance for <unittitle>
        # ASSUMPTION: one one child <did> in an element, so return the first element
        # in the array of Nokogiri::XML::Element
        def unittitle(ead_element)
          ead_element.xpath(XPATH[:unittitle]).first
        end
      end
    end
  end
end
