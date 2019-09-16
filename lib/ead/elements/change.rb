# Following class describes the EAD element <change> Change
# (https://www.loc.gov/ead/tglib/elements/change.html)
# and supplies class methods to retrieve pertinent child elements
# of the <change> element

module Ead
  module Elements
    class Change

      XPATH = {
        date: './xmlns:date',
        item: './xmlns:item'
      }.freeze

      class << self
        # returns: Nokogiri::XML::NodeSet of <date>
        # <date> Date
        def date_node_set(input_element)
          input_element.xpath(XPATH[:date])
        end

        # returns: Nokogiri::XML::NodeSet of <item>
        # <item> Item
        def item_node_set(input_element)
          input_element.xpath(XPATH[:item])
        end
      end
    end
  end
end
