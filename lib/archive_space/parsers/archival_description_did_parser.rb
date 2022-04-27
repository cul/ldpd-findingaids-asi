# this class parses the pertinent child elements of the <archdesc> that are contained within the child <did>
require 'ead/elements/did.rb'
require 'archive_space/parsers/ead_helper'

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

      def parse(nokogiri_xml_document)
        arch_desc_did = nokogiri_xml_document.xpath('/xmlns:ead/xmlns:archdesc/xmlns:did')
        # @abstracts = ::Ead::Elements::Did.abstract_array(arch_desc_did).map(&:text)
        @abstracts =
          ::Ead::Elements::Did.abstract_node_set(arch_desc_did).map do |abstract|
          ArchiveSpace::Parsers::EadHelper.apply_ead_to_html_transforms abstract
        end
        @language = ::Ead::Elements::Did.langmaterial_node_set(arch_desc_did).map(&:text).max_by(&:length)
        @origination_creators = ::Ead::Elements::Did.origination_label_attribute_creator_node_set(arch_desc_did).map(&:text).map(&:strip)
        physical_descriptions = ::Ead::Elements::Did.physdesc_node_set(arch_desc_did)
        @physical_description_extents_string =
          ArchiveSpace::Parsers::EadHelper.compound_physical_descriptions_into_string physical_descriptions
        @repository_corporate_name = ::Ead::Elements::Did.repository_corpname_node_set(arch_desc_did).first.text
        unit_dates = ::Ead::Elements::Did.unitdate_node_set(arch_desc_did)
        @unit_dates_string =
          ArchiveSpace::Parsers::EadHelper.compound_dates_into_string unit_dates
        unit_ids = ::Ead::Elements::Did.unitid_node_set(arch_desc_did)
        @unit_id_bib_id = unit_ids.first.text
        @unit_id_call_number = unit_ids[1].text if unit_ids[1]
        unit_titles = ::Ead::Elements::Did.unittitle_node_set(arch_desc_did)
        # Assume AS EAD has one and only one title
        @unit_title = unit_titles.first.text
      end
    end
  end
end
