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

      def apply_ead_to_html_transforms content
        html_content = apply_title_render_italic content
        html_content = apply_extref_type_simple html_content
      end

      def apply_title_render_italic content
        titles_render_italic = content.xpath('./xmlns:title[@render="italic"]')
        titles_render_italic.each do |title_italic|
          title_italic.replace "<i>#{title_italic.text}</i>"
        end
        content
      end

      def apply_extref_type_simple content
        extrefs_type_simple = content.xpath('./xmlns:extref[@xlink:type="simple"]')
        extrefs_type_simple.each do |extref|
          href = "\"#{extref.attribute('href')}\""
          link_text = extref.text
          extref.replace "<a href=#{href}>#{link_text}</a>"
        end
        content
      end
    end
  end
end
