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
        # <filedesc> and <publicationstmt> are not repeatable, but <publisher> is
        # returns: Nokogiri::XML::NodeSet of <publisher>
        def filedesc_publicationstmt_publisher_node_set(input_element)
          input_element.xpath(XPATH[:filedesc_publicationstmt_publisher])
        end

        # <revisiondesc> Revision Description, https://www.loc.gov/ead/tglib/elements/revisiondesc.html
        # <change> Change, https://www.loc.gov/ead/tglib/elements/change.html
        # returns: Nokogiri::XML::NodeSet of <change>
        def revisiondesc_change_node_set(input_element)
          input_element.xpath(XPATH[:revisiondesc_change])
        end
      end
    end
  end
end
