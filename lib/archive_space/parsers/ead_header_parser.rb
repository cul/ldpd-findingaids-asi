# <eadheader>
require 'ead/elements/eadheader'
require 'ead/elements/change'

module ArchiveSpace
  module Parsers
    class EadHeaderParser

      ATTRIBUTES = [
        :eadid_url_attribute,
        :publication_statement_publisher,
        :revision_description_changes,
        :title_statement_sponsor
      ]

      attr_reader *ATTRIBUTES

      Change = Struct.new(:date, :item)

      def parse(nokogiri_xml_document)
        ead_header = nokogiri_xml_document.xpath('/xmlns:ead/xmlns:eadheader')
        @eadid_url_attribute = ::Ead::Elements::Eadheader.eadid_url_attribute_array(ead_header).first.text unless
          ::Ead::Elements::Eadheader.eadid_url_attribute_array(ead_header).empty?
        @publication_statement_publisher = ::Ead::Elements::Eadheader.filedesc_publicationstmt_publisher_node_set(ead_header).first.text
        @revision_description_changes = []
        ::Ead::Elements::Eadheader.revisiondesc_change_node_set(ead_header).each do |change|
          @revision_description_changes.append Change.new(::Ead::Elements::Change.date_node_set(change).text,
                                                          ::Ead::Elements::Change.item_node_set(change).text)
        end
        # In CUL EADs, <sponsor> element appears only once, though the standard allows it to be repeatable
        @title_statement_sponsor = ::Ead::Elements::Eadheader.filedesc_titlestmt_sponsor_node_set(ead_header).first.text unless
          ::Ead::Elements::Eadheader.filedesc_titlestmt_sponsor_node_set(ead_header).empty?
      end
    end
  end
end
