# this class parses the pertinent child elements of the <archdesc> that are contained within the child <dsc>
require 'ead/elements/dsc.rb'

module ArchiveSpace
  module Parsers
    class ArchivalDescriptionDscParser

      ATTRIBUTES = [
        :series_compound_title_array,
        :subseries_compound_title_array_for_each_series_array
#        :series_date_string_array, # <ead>:<archdesc>:<c level="series">:<did>:<unitdate>
#        :series_title_array # <ead>:<archdesc>:<c level="series">:<did>:<unittile>
      ]

      attr_reader *ATTRIBUTES

      def parse(nokogiri_xml_document)
        arch_desc_dsc = nokogiri_xml_document.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc')
        series_array = ::Ead::Elements::Dsc.c_level_attribute_series_array(arch_desc_dsc)
        @series_compound_title_array = []
        @subseries_compound_title_array_for_each_series_array = []
        series_array.each do |series|
          @series_compound_title_array.append ArchiveSpace::Parsers::EadHelper.compound_title(series)
          subseries_compound_title_array = []
          ::Ead::Elements::Component.c_level_attribute_subseries_array(series).each do |subseries|
            subseries_compound_title_array.append ArchiveSpace::Parsers::EadHelper.compound_title(subseries)
          end
          @subseries_compound_title_array_for_each_series_array.append subseries_compound_title_array
        end
      end
    end
  end
end
