# this class parses the pertinent child elements of the <archdesc> that are contained within the child <did>
require 'ead/elements/did.rb'

module ArchiveSpace
  module Parsers
    class ArchivalDescriptionDidParser

      ATTRIBUTES = [
        :abstracts,
        :language,
        :origination_creators,
        :physical_description_extents_string,
        :repository_corporate_name,
        :unit_dates_string,
        :unit_id_bib_id,
        :unit_id_call_number,
        :unit_title
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
        arch_desc_did = nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:did')
        @abstracts = ::Ead::Elements::Did.abstract_array(arch_desc_did).map(&:text)
        @language = ::Ead::Elements::Did.langmaterial_array(arch_desc_did).map(&:text).max_by(&:length)
        @origination_creators = ::Ead::Elements::Did.origination_label_attribute_creator_array(arch_desc_did).map(&:text)
        physical_descriptions = ::Ead::Elements::Did.physdesc_array(arch_desc_did)
        @physical_description_extents_string = compound_physical_descriptions_into_string physical_descriptions
        @repository_corporate_name = ::Ead::Elements::Did.repository_corpname_array(arch_desc_did).first.text
        unit_dates = ::Ead::Elements::Did.unitdate_array(arch_desc_did)
        @unit_dates_string = compound_dates_into_string unit_dates
        unit_ids = ::Ead::Elements::Did.unitid_array(arch_desc_did)
        @unit_id_bib_id = unit_ids.first.text
        @unit_id_call_number = unit_ids[1].text if unit_ids[1]
        unit_titles = ::Ead::Elements::Did.unittitle_array(arch_desc_did)
        # Assume AS EAD has one and only one title
        @unit_title = unit_titles.first.text
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
