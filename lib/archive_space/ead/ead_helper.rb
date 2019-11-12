# fcd1, 05/22/19: Currently being tested via ead_parser_spec.rb
# and finding_aids_helper_spec.rb
module ArchiveSpace
  module Ead
    module EadHelper
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

      def compound_physical_descriptions_into_string physical_descriptions
        phys_desc_strings = physical_descriptions.map do |physical_description|
          space_occupied = physical_description.xpath('./xmlns:extent[@altrender="materialtype spaceoccupied"]').text
          carrier = " (#{physical_description.xpath('./xmlns:extent[@altrender="carrier"]').text})" unless
            physical_description.xpath('./xmlns:extent[@altrender="carrier"]').text.empty?
          space_occupied + ( carrier ? carrier : '')
        end
        phys_desc_strings.join('; ')
      end

      # @param content [Nokogiri::XML::Element]
      # @return [String] HTML-safe content
      def apply_ead_to_html_transforms content
        html_content = apply_title_render_italic content
        html_content = apply_extref_type_simple html_content
        html_content.to_s.html_safe
      end

      # @param content [Nokogiri::XML::Element]
      # @return [Nokogiri::XML::Element]
      def apply_title_render_italic content
        titles_render_italic = content.xpath('./xmlns:title[@render="italic"]')
        titles_render_italic.each do |title_italic|
          title_italic.replace "<i>#{title_italic.text}</i>"
        end
        content
      end

      # @param content [Nokogiri::XML::Element]
      # @return [Nokogiri::XML::Element]
      def apply_extref_type_simple content
        extrefs_type_simple = content.xpath('./xmlns:extref[@xlink:type="simple"]')
        extrefs_type_simple.each do |extref|
          href = extref.attribute('href')
          link_text = extref.text
          extref.replace "<a href=\"#{href}\">#{link_text}</a>"
        end
        content
      end

      def hightlight_offsite content
        content.match(/off+[A-Za-z-]*site/)
      end

      def accessrestrict_contains_unprocessed? content
        content.match(/unprocessed/i)
      end
    end
  end
end
