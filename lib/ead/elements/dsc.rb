# Following class describes the EAD element <dsc>
# (see https://www.loc.gov/ead/tglib/elements/dsc.html)
# and supplies class methods to retrieve pertinent child elements
# of the <dsc>

module Ead
  module Elements
    class Dsc

      XPATH = {
        c_level_attribute_series: './xmlns:c[@level="series"]'
      }.freeze

      class << self
        # returns: array of Nokogiri::XML::Element instances for top-level <c level="series">
        def c_level_attribute_series_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:c_level_attribute_series])
        end
      end

      attr_reader :nokogiri_element

      def initialize(nokogiri_element)
        reset! nokogiri_element
      end

      def reset!(nokogiri_element = nil)
        @nokogiri_element = nokogiri_element
        @series_components = nil
      end

      def c_level_attribute_series_array
        Dsc.c_level_attribute_series_array(nokogiri_element)
      end

      def c_level_attribute_series(index)
          nokogiri_element.xpath("#{XPATH[:c_level_attribute_series]}[#{index}]").first
      end

      def series_components
        @series_components ||= c_level_attribute_series_array.map { |ele| ::Ead::Elements::Component.new(ele) }
      end

      def series_component(index)
        ::Ead::Elements::Component.new(c_level_attribute_series(index))
      end
    end
  end
end
