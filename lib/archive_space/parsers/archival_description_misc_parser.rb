# this class parses the pertinent child elements of the <archdesc> that are NOT contained within the child <did> or <dsc>
require 'archive_space/ead/ead_helper'
require 'ead/elements/archdesc.rb'

module ArchiveSpace
  module Parsers
    class ArchivalDescriptionMiscParser
      include  ArchiveSpace::Ead::EadHelper

      XPATH = {
        access_restrictions_head: '/xmlns:ead/xmlns:archdesc/xmlns:accessrestrict/xmlns:head',
        access_restrictions_values: '/xmlns:ead/xmlns:archdesc/xmlns:accessrestrict/xmlns:p',
        accruals_head: '/xmlns:ead/xmlns:archdesc/xmlns:accruals/xmlns:head',
        accruals_values: '/xmlns:ead/xmlns:archdesc/xmlns:accruals/xmlns:p',
        alternative_form_available_head: '/xmlns:ead/xmlns:archdesc/xmlns:altformavail/xmlns:head',
        alternative_form_available_values: '/xmlns:ead/xmlns:archdesc/xmlns:altformavail/xmlns:p',
        arrangement_head: '/xmlns:ead/xmlns:archdesc/xmlns:arrangement/xmlns:head',
        arrangement_values: '/xmlns:ead/xmlns:archdesc/xmlns:arrangement/xmlns:p',
        biography_history_head: '/xmlns:ead/xmlns:archdesc/xmlns:bioghist/xmlns:head',
        biography_history_values: '/xmlns:ead/xmlns:archdesc/xmlns:bioghist/xmlns:p',
        control_access_corporate_name_values: '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:corpname',
        control_access_genre_form_values: '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:genreform',
        control_access_occupation_values: '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:occupation',
        control_access_personal_name_values: '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:persname',
        control_access_subject_values: '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:subject',
        conditions_governing_use_head: '/xmlns:ead/xmlns:archdesc/xmlns:userestrict/xmlns:head',
        conditions_governing_use_values: '/xmlns:ead/xmlns:archdesc/xmlns:userestrict/xmlns:p',
        other_descriptive_data_head: '/xmlns:ead/xmlns:archdesc/xmlns:odd/xmlns:head',
        other_descriptive_data_values: '/xmlns:ead/xmlns:archdesc/xmlns:odd/xmlns:p',
        other_finding_aid_head: '/xmlns:ead/xmlns:archdesc/xmlns:otherfindaid/xmlns:head',
        other_finding_aid_values: '/xmlns:ead/xmlns:archdesc/xmlns:otherfindaid/xmlns:p',
        preferred_citation_head: '/xmlns:ead/xmlns:archdesc/xmlns:prefercite/xmlns:head',
        preferred_citation_values: '/xmlns:ead/xmlns:archdesc/xmlns:prefercite/xmlns:p',
        processing_information_head: '/xmlns:ead/xmlns:archdesc/xmlns:processinfo/xmlns:head',
        processing_information_values: '/xmlns:ead/xmlns:archdesc/xmlns:processinfo/xmlns:p',
        related_material_head: '/xmlns:ead/xmlns:archdesc/xmlns:relatedmaterial/xmlns:head',
        related_material_values: '/xmlns:ead/xmlns:archdesc/xmlns:relatedmaterial/xmlns:p',
        scope_and_content_head: '/xmlns:ead/xmlns:archdesc/xmlns:scopecontent/xmlns:head',
        scope_and_content_values: '/xmlns:ead/xmlns:archdesc/xmlns:scopecontent/xmlns:p',
        separated_material_head: '/xmlns:ead/xmlns:archdesc/xmlns:separatedmaterial/xmlns:head',
        separated_material_values: '/xmlns:ead/xmlns:archdesc/xmlns:separatedmaterial/xmlns:p'
      }

      attr_reader *XPATH.keys

      def parse(nokogiri_xml_document)
        arch_desc = nokogiri_xml_document.xpath('/xmlns:ead/xmlns:archdesc')
        @access_restrictions_head = ::Ead::Elements::Archdesc.accessrestrict_head_array(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.accessrestrict_head_array(arch_desc).empty?
        @access_restrictions_values = ::Ead::Elements::Archdesc.accessrestrict_p_array(arch_desc).map(&:text)
        @accruals_head = ::Ead::Elements::Archdesc.accruals_head_array(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.accruals_head_array(arch_desc).empty?
        @accruals_values = ::Ead::Elements::Archdesc.accruals_p_array(arch_desc).map(&:text)
        @alternative_form_available_head = ::Ead::Elements::Archdesc.altformavail_head_array(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.altformavail_head_array(arch_desc).empty?
        @alternative_form_available_values = ::Ead::Elements::Archdesc.altformavail_p_array(arch_desc).map(&:text)
        @arrangement_head = ::Ead::Elements::Archdesc.arrangement_head_array(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.arrangement_head_array(arch_desc).empty?
        @arrangement_values = ::Ead::Elements::Archdesc.arrangement_p_array(arch_desc).map(&:text)
        @biography_history_head = ::Ead::Elements::Archdesc.bioghist_head_array(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.bioghist_head_array(arch_desc).empty?
        @biography_history_values = ::Ead::Elements::Archdesc.bioghist_p_array(arch_desc).map(&:text)
        control_access_array = ::Ead::Elements::Archdesc.controlaccess_array(arch_desc)
        @control_access_corporate_name_values = []
        @control_access_genre_form_values = []
        @control_access_occupation_values = []
        @control_access_personal_name_values = []
        @control_access_subject_values = []
        control_access_array.each do |control_access|
          @control_access_corporate_name_values.concat control_access.xpath('./xmlns:corpname').map(&:text)
          @control_access_genre_form_values.concat control_access.xpath('./xmlns:genreform').map(&:text)
          @control_access_occupation_values.concat control_access.xpath('./xmlns:occupation').map(&:text)
          @control_access_personal_name_values.concat control_access.xpath('./xmlns:persname').map(&:text)
          @control_access_subject_values.concat control_access.xpath('./xmlns:subject').map(&:text)
        end
        @conditions_governing_use_head = ::Ead::Elements::Archdesc.userestrict_head_array(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.userestrict_head_array(arch_desc).empty?
        @conditions_governing_use_values = ::Ead::Elements::Archdesc.userestrict_p_array(arch_desc).map(&:text)
        @other_descriptive_data_head = ::Ead::Elements::Archdesc.odd_head_array(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.odd_head_array(arch_desc).empty?
        @other_descriptive_data_values = ::Ead::Elements::Archdesc.odd_p_array(arch_desc).map(&:text)
        @other_finding_aid_head = ::Ead::Elements::Archdesc.otherfindaid_head_array(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.otherfindaid_head_array(arch_desc).empty?
        @other_finding_aid_values = ::Ead::Elements::Archdesc.otherfindaid_p_array(arch_desc).map(&:text)
        @preferred_citation_head = ::Ead::Elements::Archdesc.prefercite_head_array(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.prefercite_head_array(arch_desc).empty?
        @preferred_citation_values = ::Ead::Elements::Archdesc.prefercite_p_array(arch_desc).map(&:text)
        @processing_information_head = ::Ead::Elements::Archdesc.processinfo_head_array(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.processinfo_head_array(arch_desc).empty?
        @processing_information_values = ::Ead::Elements::Archdesc.processinfo_p_array(arch_desc).map(&:text)
        @related_material_head = ::Ead::Elements::Archdesc.relatedmaterial_head_array(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.relatedmaterial_head_array(arch_desc).empty?
        @related_material_values = ::Ead::Elements::Archdesc.relatedmaterial_p_array(arch_desc).map(&:text)
        @scope_and_content_head = ::Ead::Elements::Archdesc.scopecontent_head_array(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.scopecontent_head_array(arch_desc).empty?
        @scope_and_content_values = ::Ead::Elements::Archdesc.scopecontent_p_array(arch_desc).map(&:text)
        @separated_material_head = ::Ead::Elements::Archdesc.separatedmaterial_head_array(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.separatedmaterial_head_array(arch_desc).empty?
        @separated_material_values = ::Ead::Elements::Archdesc.separatedmaterial_p_array(arch_desc).map(&:text)
      end

      # fcd1, 09/02/19: NEED TO RETHNK/REIMPLEMENT THIS
      def series_scope_content_values
        series_nokogiri_elements =
          @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]')
        series_scope_content = series_nokogiri_elements.map do |series|
          series.xpath('./xmlns:scopecontent/xmlns:p')
        end
      end

      # fcd1, 09/02/19: NEED TO RETHNK/REIMPLEMENT THIS
      # fcd1, 03/11/19: Continure refactoring following when time allows
      # Note: arg start from 1, but array start at index 0
      def get_files_info_for_series(i)
        series_file_info_nokogiri_elements =
          @dsc_series[i.to_i - 1].xpath('./xmlns:c[@level="file"]')
        series_files_info = series_file_info_nokogiri_elements.map do |file_info_nokogiri_element|
          title = file_info_nokogiri_element.xpath('./xmlns:did/xmlns:unittitle').text
          box_number = file_info_nokogiri_element.xpath('./xmlns:did/xmlns:container').text
          {title: title, box_number: box_number}
        end
      end
    end
  end
end
