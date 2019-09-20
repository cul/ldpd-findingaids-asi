# <eadheader>
require 'ead/elements/eadheader'
require 'ead/elements/change'

module ArchiveSpace
  module Parsers
    class EadHeaderParser

      ATTRIBUTES = [
        :publication_statement_publisher,
        :revision_description_changes
      ]

      attr_reader *ATTRIBUTES

      Change = Struct.new(:date, :item)

      def parse(nokogiri_xml_document)
        ead_header = nokogiri_xml_document.xpath('/xmlns:ead/xmlns:eadheader')
        @publication_statement_publisher = ::Ead::Elements::Eadheader.filedesc_publicationstmt_publisher_node_set(ead_header).first.text
        @revision_description_changes = []
        ::Ead::Elements::Eadheader.revisiondesc_change_node_set(ead_header).each do |change|
          @revision_description_changes.append Change.new(::Ead::Elements::Change.date_node_set(change).text,
                                                          ::Ead::Elements::Change.item_node_set(change).text)
        end
      end
    end
  end
end
