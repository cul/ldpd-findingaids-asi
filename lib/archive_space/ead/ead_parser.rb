require 'net/http'

module ArchiveSpace
  module Ead
    class EadParser
      XPATH = {
        archive_abstract: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:abstract',
        archive_access_restrictions_head: '/xmlns:ead/xmlns:archdesc/xmlns:accessrestrict/xmlns:head',
        archive_access_restrictions_values: '/xmlns:ead/xmlns:archdesc/xmlns:accessrestrict/xmlns:p',
        archive_accruals_head: '/xmlns:ead/xmlns:archdesc/xmlns:accruals/xmlns:head',
        archive_accruals_values: '/xmlns:ead/xmlns:archdesc/xmlns:accruals/xmlns:p',
        archive_alternative_form_available_head: '/xmlns:ead/xmlns:archdesc/xmlns:altformavail/xmlns:head',
        archive_alternative_form_available_values: '/xmlns:ead/xmlns:archdesc/xmlns:altformavail/xmlns:p',
        archive_biography_history_head: '/xmlns:ead/xmlns:archdesc/xmlns:bioghist/xmlns:head',
        archive_biography_history_values: '/xmlns:ead/xmlns:archdesc/xmlns:bioghist/xmlns:p',
        archive_control_access_corpnames: '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:corpname',
        archive_control_access_genres_forms: '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:genreform',
        archive_control_access_occupations: '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:occupation',
        archive_control_access_persnames: '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:persname',
        archive_control_access_subjects: '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:subject',
        archive_date: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:unitdate',
        archive_dsc_series: '/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]',
        archive_dsc_series_titles: '/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]/xmlns:did/xmlns:unittitle',
        archive_id: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:unitid',
        archive_language: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:langmaterial',
        archive_origination_creator: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:origination[@label="creator"]',
        archive_physical_description_extent_carrier: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:physdesc/xmlns:extent[@altrender="carrier"]',
        archive_preferred_citation_head: '/xmlns:ead/xmlns:archdesc/xmlns:prefercite/xmlns:head',
        archive_preferred_citation_values: '/xmlns:ead/xmlns:archdesc/xmlns:prefercite/xmlns:p',
        archive_processing_information_head: '/xmlns:ead/xmlns:archdesc/xmlns:processinfo/xmlns:head',
        archive_processing_information_values: '/xmlns:ead/xmlns:archdesc/xmlns:processinfo/xmlns:p',
        archive_related_material_head: '/xmlns:ead/xmlns:archdesc/xmlns:relatedmaterial/xmlns:head',
        archive_related_material_values: '/xmlns:ead/xmlns:archdesc/xmlns:relatedmaterial/xmlns:p',
        archive_repository: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:repository/xmlns:corpname',
        archive_revision_description_changes: '/xmlns:ead/xmlns:eadheader/xmlns:revisiondesc/xmlns:change',
        archive_scope_content_head: '/xmlns:ead/xmlns:archdesc/xmlns:scopecontent/xmlns:head',
        archive_scope_content_values: '/xmlns:ead/xmlns:archdesc/xmlns:scopecontent/xmlns:p',
        archive_title: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:unittitle',
        archive_use_restrictions_head: '/xmlns:ead/xmlns:archdesc/xmlns:userestrict/xmlns:head',
        archive_use_restrictions_values: '/xmlns:ead/xmlns:archdesc/xmlns:userestrict/xmlns:p'
      }

      attr_reader *XPATH.keys

      def initialize(xml_input)
        @nokogiri_xml = Nokogiri::XML(xml_input)
        parse_ead_header(@nokogiri_xml)
        parse_arch_desc_did(@nokogiri_xml)
        parse_arch_desc_dsc(@nokogiri_xml)
        parse_arch_desc_misc(@nokogiri_xml)
      end

      # make private? Makes unit test harder
      def parse_ead_header(nokogiri_xml)
        revision_description_change_nokogiri_elements =
          nokogiri_xml.xpath(XPATH[:archive_revision_description_changes])
        @archive_revision_description_changes = revision_description_change_nokogiri_elements.map do |change|
          {date: change.xpath('./xmlns:date').text, item: change.xpath('./xmlns:item').text}
        end
      end

      # make private? Makes unit test harder
      def parse_arch_desc_did(nokogiri_xml)
        @archive_abstract = nokogiri_xml.xpath(XPATH[:archive_abstract]).text
        @archive_date = nokogiri_xml.xpath(XPATH[:archive_date]).text
        @archive_id = nokogiri_xml.xpath(XPATH[:archive_id]).text
        @archive_language = nokogiri_xml.xpath(XPATH[:archive_language]).map(&:text).max_by(&:length)
        @archive_origination_creator = nokogiri_xml.xpath(XPATH[:archive_origination_creator]).text
        @archive_physical_description_extent_carrier = nokogiri_xml.xpath(XPATH[:archive_physical_description_extent_carrier]).text
        @archive_repository = nokogiri_xml.xpath(XPATH[:archive_repository]).text
        @archive_title = nokogiri_xml.xpath(XPATH[:archive_title]).text
      end

      # make private? Makes unit test harder
      def parse_arch_desc_dsc(nokogiri_xml)
        series_title_nokogiri_elements =
          nokogiri_xml.xpath(XPATH[:archive_dsc_series_titles])
        @archive_dsc_series_titles = series_title_nokogiri_elements.map do |series|
          series.text
        end
        @archive_dsc_series = nokogiri_xml.xpath(XPATH[:archive_dsc_series])
      end

      # make private? Makes unit test harder
      def parse_arch_desc_misc(nokogiri_xml)
        @archive_access_restrictions_head = nokogiri_xml.xpath(XPATH[:archive_access_restrictions_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:archive_access_restrictions_head]).first.nil?
        @archive_access_restrictions_values = nokogiri_xml.xpath(XPATH[:archive_access_restrictions_values])
        @archive_accruals_head = nokogiri_xml.xpath(XPATH[:archive_accruals_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:archive_accruals_head]).first.nil?
        @archive_accruals_values = nokogiri_xml.xpath(XPATH[:archive_accruals_values])
        @archive_alternative_form_available_head = nokogiri_xml.xpath(XPATH[:archive_alternative_form_available_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:archive_alternative_form_available_head]).first.nil?
        @archive_alternative_form_available_values = nokogiri_xml.xpath(XPATH[:archive_alternative_form_available_values])
        @archive_biography_history_head = nokogiri_xml.xpath(XPATH[:archive_biography_history_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:archive_biography_history_head]).first.nil?
        @archive_biography_history_values = nokogiri_xml.xpath(XPATH[:archive_biography_history_values])
        @archive_control_access_corpnames = nokogiri_xml.xpath(XPATH[:archive_control_access_corpnames]).map(&:text)
        @archive_control_access_genres_forms = nokogiri_xml.xpath(XPATH[:archive_control_access_genres_forms]).map(&:text)
        @archive_control_access_occupations = nokogiri_xml.xpath(XPATH[:archive_control_access_occupations]).map(&:text)
        @archive_control_access_persnames = nokogiri_xml.xpath(XPATH[:archive_control_access_persnames]).map(&:text)
        @archive_control_access_subjects = nokogiri_xml.xpath(XPATH[:archive_control_access_subjects]).map(&:text)
        @archive_preferred_citation_head = nokogiri_xml.xpath(XPATH[:archive_preferred_citation_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:archive_preferred_citation_head]).first.nil?
        @archive_preferred_citation_values = nokogiri_xml.xpath(XPATH[:archive_preferred_citation_values])
        @archive_processing_information_head = nokogiri_xml.xpath(XPATH[:archive_processing_information_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:archive_processing_information_head]).first.nil?
        @archive_processing_information_values = nokogiri_xml.xpath(XPATH[:archive_processing_information_values])
        @archive_related_material_head = nokogiri_xml.xpath(XPATH[:archive_related_material_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:archive_related_material_head]).first.nil?
        @archive_related_material_values = nokogiri_xml.xpath(XPATH[:archive_related_material_values])
        @archive_scope_content_head = nokogiri_xml.xpath(XPATH[:archive_scope_content_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:archive_scope_content_head]).first.nil?
        @archive_scope_content_values = nokogiri_xml.xpath(XPATH[:archive_scope_content_values])
        @archive_use_restrictions_head = nokogiri_xml.xpath(XPATH[:archive_use_restrictions_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:archive_use_restrictions_head]).first.nil?
        @archive_use_restrictions_values = nokogiri_xml.xpath(XPATH[:archive_use_restrictions_values])
      end

      def get_series_scope_content
        series_nokogiri_elements =
          @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]')
        series_scope_content = series_nokogiri_elements.map do |series|
          series.xpath('./xmlns:scopecontent/xmlns:p').text
        end
      end

      # fcd1, 03/11/19: Continure refactoring following when time allows
      # Note: arg start from 1, but array start at index 0
      def get_files_info_for_series(i)
        series_file_info_nokogiri_elements =
          @archive_dsc_series[i.to_i - 1].xpath('./xmlns:c[@level="file"]')
        series_files_info = series_file_info_nokogiri_elements.map do |file_info_nokogiri_element|
          title = file_info_nokogiri_element.xpath('./xmlns:did/xmlns:unittitle').text
          box_number = file_info_nokogiri_element.xpath('./xmlns:did/xmlns:container').text
          {title: title, box_number: box_number}
        end
      end
    end
  end
end
