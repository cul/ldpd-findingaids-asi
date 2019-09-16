# this class parses the pertinent child elements of the <archdesc> that are contained within the child <dsc>
require 'ead/elements/dsc.rb'

module ArchiveSpace
  module Parsers
    class ArchivalDescriptionDscParser

      ATTRIBUTES = [
        :scope_content_values_for_each_series,
        :series_compound_title_array,
        # Following attribute is a hash, with each key being a series compound title, and the value
        # for that key is an array of the subseries compound titles for the subseries
        # contained within that series
        :series_subseries_compound_titles_hash,
        :subseries_compound_title_array_for_each_series_array
#        :series_date_string_array, # <ead>:<archdesc>:<c level="series">:<did>:<unitdate>
#        :series_title_array # <ead>:<archdesc>:<c level="series">:<did>:<unittile>
      ]

      attr_reader *ATTRIBUTES

      def parse(nokogiri_xml_document)
        arch_desc_dsc = nokogiri_xml_document.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc')
        series_array = ::Ead::Elements::Dsc.c_level_attribute_series_array(arch_desc_dsc)
        @scope_content_values_for_each_series = []
        @series_compound_title_array = []
        @series_subseries_compound_titles_hash = {}
        @subseries_compound_title_array_for_each_series_array = []
        series_array.each do |series|
          series_compound_title = ArchiveSpace::Parsers::EadHelper.compound_title(series)
          @series_compound_title_array.append series_compound_title
          subseries_compound_title_array = []
          ::Ead::Elements::Component.c_level_attribute_subseries_node_set(series).each do |subseries|
            subseries_compound_title_array.append ArchiveSpace::Parsers::EadHelper.compound_title(subseries)
          end
          @series_subseries_compound_titles_hash[series_compound_title] =
            subseries_compound_title_array
          @subseries_compound_title_array_for_each_series_array.append subseries_compound_title_array
          scope_content_array = ::Ead::Elements::Component.scopecontent_p_node_set(series)
          @scope_content_values_for_each_series.append scope_content_array
        end
      end
    end
  end
end
