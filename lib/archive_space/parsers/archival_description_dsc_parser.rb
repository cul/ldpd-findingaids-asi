# this class parses the pertinent child elements of the <archdesc> that are contained within the child <dsc>
require 'ead/elements/dsc.rb'

module ArchiveSpace
  module Parsers
    class ArchivalDescriptionDscParser

      ATTRIBUTES = [
        :dsc,
        :scope_content_values_for_each_series,
        :series_compound_title_array,
        # Following attribute is a hash, with each key being a series compound title, and the value
        # for that key is an array of the subseries compound titles for the subseries
        # contained within that series
        :subseries_compound_title_array_for_each_series_array
#        :series_date_string_array, # <ead>:<archdesc>:<c level="series">:<did>:<unitdate>
#        :series_title_array # <ead>:<archdesc>:<c level="series">:<did>:<unittile>
      ]

      attr_reader *ATTRIBUTES

      def series_compound_title_array
        @dsc.series_components.map(&:compound_title_string)
      end

      def subseries_compound_title_array_for_each_series_array
        @dsc.series_components.map { |series| series.subseries_components.map(&:compound_title_string) }
      end

      def scope_content_values_for_each_series
        @dsc.series_components.map { |series| series.scope_content_array }
      end

      def parse(nokogiri_xml_document)
        arch_desc_dsc = nokogiri_xml_document.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc')
        @dsc = ::Ead::Elements::Dsc.new(arch_desc_dsc)
      end
    end
  end
end
