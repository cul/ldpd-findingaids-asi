# fcd1, 05/22/19: Currently being tested via ead_parser_spec.rb
# and finding_aids_helper_spec.rb

require 'ead/elements/component'
require 'ead/elements/physdesc'

module ArchiveSpace
  module Parsers
    module EadHelper
      class << self
        def compound_title component
          did = ::Ead::Elements::Component.did_node_set(component).first
          unit_title = ::Ead::Elements::Did.unittitle_node_set(did).first
          unit_dates_string = compound_dates_into_string(::Ead::Elements::Did.unitdate_node_set(did))
          # compound_title contains the unit title and the unit date(s)
          [unit_title, unit_dates_string].reject(&:blank?).join(', ')
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

        def compound_physical_descriptions_into_string physical_descriptions
          phys_desc_strings = physical_descriptions.map do |physical_description|
            space_occupied = physical_description.xpath('./xmlns:extent[@altrender="materialtype spaceoccupied"]').text
            carrier = " (#{physical_description.xpath('./xmlns:extent[@altrender="carrier"]').text})" unless
              physical_description.xpath('./xmlns:extent[@altrender="carrier"]').text.empty?
            space_occupied + ( carrier ? carrier : '')
          end
          phys_desc_strings.join('; ')
        end

        def component_physical_descriptions_string physical_descriptions
          phys_desc_strings_array = []
          physical_descriptions.each do |physical_description|
            ::Ead::Elements::Physdesc.extent_node_set(physical_description).each do |extent|
              phys_desc_strings_array.append extent.content.strip unless extent.content.blank?
            end
            ::Ead::Elements::Physdesc.physfacet_node_set(physical_description).each do |physical_facet|
              phys_desc_strings_array.append physical_facet.content.strip unless physical_facet.content.blank?
            end
            phys_desc_text = physical_description.xpath('./text()').text.strip
            phys_desc_strings_array.append phys_desc_text unless phys_desc_text.blank?
          end
          phys_desc_strings_array.join('; ')
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

        def highlight_offsite content
          content.match(/off+[A-Za-z-]*site/)
        end

        def accessrestrict_contains_unprocessed? content
          content.match(/unprocessed/i)
        end
      end
    end
  end
end
