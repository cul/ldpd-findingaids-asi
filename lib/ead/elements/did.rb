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
        unit_dates: './xmlns:did/xmlns:unitdate',
        unit_titles: './xmlns:did/xmlns:unittitle'
      }.freeze

      class << self
        # nokogiri_element parameter: Nokogiri::XML::NodeSet representing the EAD parent element containing the <did>
        # returns: array of Nokogiri::XML::Element
        def unit_dates(nokogiri_element)
          # puts nokogiri_element
          nokogiri_element.xpath(XPATH[:unit_dates])
        end

        # ead_element parameter: parent element containing the <did>
        def unit_titles(ead_element)
          ead_element.xpath(XPATH[:unit_titles])
        end
      end
    end
  end
end
