# this class parses the pertinent child elements of the <archdesc> that are contained within the child <did>
require 'ead/elements/did.rb'

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

      def parse(xml_input, recover_mode = false)
        if recover_mode
          # The RECOVER parse option is set by default, where Nokogiri will attempt to recover from errors
          nokogiri_xml = Nokogiri::XML(xml_input)
        else
          # turn RECOVER parse option off. Will throw a Nokogiri::XML::SyntaxError if parsing error encountered
          nokogiri_xml = Nokogiri::XML(xml_input) do |config|
            config.norecover
          end
        end
        arch_desc_dsc = nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc')
        series_array = ::Ead::Elements::Dsc.c_level_attribute_series_array(arch_desc_dsc)
        @series_compound_title_array = []
        @subseries_compound_title_array_for_each_series_array = []
        series_array.each do |series|
          @series_compound_title_array.append compound_title(series)
          subseries_compound_title_array = []
          ::Ead::Elements::Component.c_level_attribute_subseries_array(series).each do |subseries|
            subseries_compound_title_array.append compound_title(subseries)
          end
          @subseries_compound_title_array_for_each_series_array.append subseries_compound_title_array
        end
      end

      def compound_title component
          did = ::Ead::Elements::Component.did(component)
          unit_title = ::Ead::Elements::Did.unittitle_array(did).first
          unit_dates_string = compound_dates_into_string(::Ead::Elements::Did.unitdate_array(did))
          # compound_title contains the unit title and the unit date(s)
          [unit_title, unit_dates_string].reject(&:blank?).join(', ')
      end

      def compound_physical_descriptions_into_string physical_descriptions
        phys_desc_strings = physical_descriptions.map do |physical_description|
          space_occupied = physical_description.xpath('./xmlns:extent[@altrender="materialtype spaceoccupied"]').text
          carrier = " (#{physical_description.xpath('./xmlns:extent[@altrender="carrier"]').text})" unless
            physical_description.xpath('./xmlns:extent[@altrender="carrier"]').text.empty?
          space_occupied + ( carrier ? carrier : '')
        end
        phys_desc_strings.join('; ')
      end

      def compound_dates_into_string unit_dates
        bulk_dates = []
        non_bulk_dates = []
        unit_dates.each do |unit_date|
          if unit_date['type'] == 'bulk'
            bulk_dates.append "bulk #{unit_date.text}"
          else
            non_bulk_dates.append "#{unit_date.text}"
          end
        end
        non_bulk_dates.concat(bulk_dates).join(', ')
      end      
    end
  end
end
