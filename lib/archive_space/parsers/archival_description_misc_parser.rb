# this class parses the pertinent child elements of the <archdesc> that are NOT contained within the child <did> or <dsc>
require 'archive_space/ead/ead_helper'
require 'ead/elements/archdesc'
require 'ead/elements/controlaccess'

module ArchiveSpace
  module Parsers
    class ArchivalDescriptionMiscParser
      include  ArchiveSpace::Ead::EadHelper

      ATTRIBUTES = [
        :access_restrictions_head,
        :access_restrictions_values,
        :accruals_head,
        :accruals_values,
        :alternative_form_available_head,
        :alternative_form_available_values,
        :arrangement_head,
        :arrangement_values,
        :biography_history_head,
        :biography_history_values,
        :control_access_corporate_name_values,
        :control_access_genre_form_values,
        :control_access_occupation_values,
        :control_access_personal_name_values,
        :control_access_subject_values,
        :conditions_governing_use_head,
        :conditions_governing_use_values,
        :other_descriptive_data_head,
        :other_descriptive_data_values,
        :other_finding_aid_head,
        :other_finding_aid_values,
        :preferred_citation_head,
        :preferred_citation_values,
        :processing_information_head,
        :processing_information_values,
        :related_material_head,
        :related_material_values,
        :scope_and_content_head,
        :scope_and_content_values,
        :separated_material_head,
        :separated_material_values
      ]

      attr_reader *ATTRIBUTES

      def parse(nokogiri_xml_document)
        arch_desc = nokogiri_xml_document.xpath('/xmlns:ead/xmlns:archdesc')
        @access_restrictions_head = ::Ead::Elements::Archdesc.accessrestrict_head_node_set(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.accessrestrict_head_node_set(arch_desc).empty?
        @access_restrictions_values = ::Ead::Elements::Archdesc.accessrestrict_p_node_set(arch_desc)
        @accruals_head = ::Ead::Elements::Archdesc.accruals_head_node_set(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.accruals_head_node_set(arch_desc).empty?
        @accruals_values = ::Ead::Elements::Archdesc.accruals_p_node_set(arch_desc)
        @alternative_form_available_head = ::Ead::Elements::Archdesc.altformavail_head_node_set(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.altformavail_head_node_set(arch_desc).empty?
        @alternative_form_available_values = ::Ead::Elements::Archdesc.altformavail_p_node_set(arch_desc)
        @arrangement_head = ::Ead::Elements::Archdesc.arrangement_head_node_set(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.arrangement_head_node_set(arch_desc).empty?
        @arrangement_values = ::Ead::Elements::Archdesc.arrangement_p_node_set(arch_desc)
        @biography_history_head = ::Ead::Elements::Archdesc.bioghist_head_node_set(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.bioghist_head_node_set(arch_desc).empty?
        @biography_history_values = ::Ead::Elements::Archdesc.bioghist_p_node_set(arch_desc)
        control_access_array = ::Ead::Elements::Archdesc.controlaccess_node_set(arch_desc)
        @control_access_corporate_name_values = []
        @control_access_genre_form_values = []
        @control_access_occupation_values = []
        @control_access_personal_name_values = []
        @control_access_subject_values = []
        control_access_array.each do |control_access|
          @control_access_corporate_name_values.concat ::Ead::Elements::Controlaccess.corpname_array(control_access).map(&:text)
          @control_access_genre_form_values.concat ::Ead::Elements::Controlaccess.genreform_array(control_access).map(&:text)
          @control_access_occupation_values.concat ::Ead::Elements::Controlaccess.occupation_array(control_access).map(&:text)
          @control_access_personal_name_values.concat ::Ead::Elements::Controlaccess.persname_array(control_access).map(&:text)
          @control_access_subject_values.concat ::Ead::Elements::Controlaccess.subject_array(control_access).map(&:text)
        end
        @conditions_governing_use_head = ::Ead::Elements::Archdesc.userestrict_head_node_set(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.userestrict_head_node_set(arch_desc).empty?
        @conditions_governing_use_values = ::Ead::Elements::Archdesc.userestrict_p_node_set(arch_desc)
        @other_descriptive_data_head = ::Ead::Elements::Archdesc.odd_head_node_set(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.odd_head_node_set(arch_desc).empty?
        @other_descriptive_data_values = ::Ead::Elements::Archdesc.odd_p_node_set(arch_desc)
        @other_finding_aid_head = ::Ead::Elements::Archdesc.otherfindaid_head_node_set(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.otherfindaid_head_node_set(arch_desc).empty?
        @other_finding_aid_values = ::Ead::Elements::Archdesc.otherfindaid_p_node_set(arch_desc)
        @preferred_citation_head = ::Ead::Elements::Archdesc.prefercite_head_node_set(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.prefercite_head_node_set(arch_desc).empty?
        @preferred_citation_values = ::Ead::Elements::Archdesc.prefercite_p_node_set(arch_desc)
        @processing_information_head = ::Ead::Elements::Archdesc.processinfo_head_node_set(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.processinfo_head_node_set(arch_desc).empty?
        @processing_information_values = ::Ead::Elements::Archdesc.processinfo_p_node_set(arch_desc)
        @related_material_head = ::Ead::Elements::Archdesc.relatedmaterial_head_node_set(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.relatedmaterial_head_node_set(arch_desc).empty?
        @related_material_values = ::Ead::Elements::Archdesc.relatedmaterial_p_node_set(arch_desc)
        @scope_and_content_head = ::Ead::Elements::Archdesc.scopecontent_head_node_set(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.scopecontent_head_node_set(arch_desc).empty?
        @scope_and_content_values = ::Ead::Elements::Archdesc.scopecontent_p_node_set(arch_desc)
        @separated_material_head = ::Ead::Elements::Archdesc.separatedmaterial_head_node_set(arch_desc).first.text unless
          ::Ead::Elements::Archdesc.separatedmaterial_head_node_set(arch_desc).empty?
        @separated_material_values = ::Ead::Elements::Archdesc.separatedmaterial_p_node_set(arch_desc)
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
