# Following class describes the EAD element <change>
# (see https://www.loc.gov/ead/tglib/elements/did.html)
# and supplies class methods to retrieve pertinent child elements
# of the <change>

module Ead
  module Elements
    class Change

      XPATH = {
        date: './xmlns:date',
        item: './xmlns:item'
      }.freeze

      class << self
        # returns: Nokogiri::XML::Element instance for <date> contained with a <change>
        # <date> Date
        def date(nokogiri_element)
          nokogiri_element.xpath(XPATH[:date])
        end

        # returns: Nokogiri::XML::Element instance for <item> contained with a <change>
        # <item> Item
        def item(nokogiri_element)
          nokogiri_element.xpath(XPATH[:item])
        end
      end
    end
  end
end
