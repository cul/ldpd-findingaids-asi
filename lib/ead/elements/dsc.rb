# Following class describes the EAD element <dsc>
# (see https://www.loc.gov/ead/tglib/elements/dsc.html)
# and supplies class methods to retrieve pertinent child elements
# of the <dsc>
require 'archive_space/ead/ead_helper'

module Ead
  module Elements
    class Dsc
      include  ArchiveSpace::Ead::EadHelper

      XPATH = {
        c_level_attribute_series: './xmlns:c[@level="series"]'
      }.freeze

      class << self
        # returns: array of Nokogiri::XML::Element instances for top-level <c level="series">
        def c_level_attribute_series_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:c_level_attribute_series])
        end
      end
    end
  end
end
