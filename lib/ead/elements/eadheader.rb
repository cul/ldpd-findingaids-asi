# Following class describes the EAD element <eadheader> EAD Header
# (see https://www.loc.gov/ead/tglib/elements/eadheader.html)
# and supplies class methods to retrieve child elements
# of the <eadheader>
require 'archive_space/ead/ead_helper'

module Ead
  module Elements
    class Eadheader

      XPATH = {
        filedesc_publicationstmt_publisher: './xmlns:filedesc/xmlns:publicationstmt/xmlns:publisher',
        revisiondesc_change: './xmlns:revisiondesc/xmlns:change'
      }.freeze

      class << self
        # <filedesc> File Description, <publicationstmt> Publication Statement, <publisher> Publisher
        # <publicationstmt> is not repeatable
        # returns: array of one Nokogiri::XML::Element representing the <publisher> element
        def filedesc_publicationstmt_publisher(nokogiri_element)
          nokogiri_element.xpath(XPATH[:filedesc_publicationstmt_publisher]).first
        end

        # <revisiondesc> Revision Description, https://www.loc.gov/ead/tglib/elements/revisiondesc.html
        # <change> Change, https://www.loc.gov/ead/tglib/elements/change.html
        # returns: array of Nokogiri::XML::Element instances representing the <change> element(s)
        def revisiondesc_change_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:revisiondesc_change])
        end
      end
    end
  end
end
