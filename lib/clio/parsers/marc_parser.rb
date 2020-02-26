# this class parses the pertinent child elements of the <archdesc> that are contained within the child <did>
require 'ead/elements/did.rb'
require 'archive_space/parsers/ead_helper'

module Clio
  module Parsers
    class MarcParser

      ATTRIBUTES = [
        :abstracts,
        :language,
        :creators,
        :physical_description_extents_string,
        :repository_corporate_name,
        :unit_dates_string,
        :unit_id_bib_id,
        :unit_id_call_number,
        :compound_title,
        :title
      ]

      attr_reader *ATTRIBUTES

      def parse(marc_record)
        # puts marc_record.inspect
        title_dates = [title_statement_title(marc_record),
                       title_statement_inclusive_dates(marc_record),
                       title_statement_bulk_dates(marc_record)]
        # puts title_dates.inspect
        # puts title_dates.reject(&:blank?).map(&(Proc.new {|x| x.chomp(',')})).join(", ")
        @compound_title = title_dates.reject(&:blank?).map(&(Proc.new {|x| x.chomp(',')})).join(", ")
        # puts @compound_title
        creators = []
        creators.append general_information_personal_names(marc_record)
        creators.append general_information_corporate_names(marc_record)
        @creators = creators.reject(&:blank?).join(", ")
        # puts @creators
      end

      def location_classification_part(marc_record)
        # fcd1, 02/26/20: For now, assume just one 852 field
        marc_record.fields('852').first['h']
      end

      def location_location(marc_record)
        # fcd1, 02/26/20: For now, assume just one 852 field
        marc_record.fields('852').first['a']
      end

      def general_information_corporate_names(marc_record)
        marc_record.fields('110').map { |x| x['a'] }
      end

      def general_information_personal_names(marc_record)
        marc_record.fields('100').map { |x| x['a'] }
      end

      def title_statement_bulk_dates(marc_record)
        # fcd1, 02/26/20: For now, assume just one 245 field
        marc_record.fields('245').first['g']
      end

      def title_statement_inclusive_dates(marc_record)
        # fcd1, 02/26/20: For now, assume just one 245 field
        marc_record.fields('245').first['f']
      end

      def title_statement_title(marc_record)
        # fcd1, 02/26/20: For now, assume just one 245 field
        marc_record.fields('245').first['a']
      end
    end
  end
end
