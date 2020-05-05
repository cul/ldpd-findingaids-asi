# Following class describes the EAD element <eadheader> EAD Header
# (see https://www.loc.gov/ead/tglib/elements/eadheader.html)
# and supplies class methods to retrieve child elements
# of the <eadheader>

module Ead
  module Elements
    class Eadheader

      XPATH = {
        eadid_url_attribute: './xmlns:eadid/@url',
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

        # <eadid> EAD Identifier, https://www.loc.gov/ead/tglib/elements/eadid.html
        # <eadid> may contain a url attribute
        # returns: Array of Nokogiri::XML::Attr representing the url attribute
        def eadid_url_attribute_array(input_element)
          input_element.xpath(XPATH[:eadid_url_attribute])
        end
      end
    end
  end
end
