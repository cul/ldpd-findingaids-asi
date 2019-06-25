require 'archive_space/ead/ead_helper'

module ArchiveSpace
  module Ead
    class EadParser
      include  ArchiveSpace::Ead::EadHelper

      XPATH = {
        abstracts: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:abstract',
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
        control_access_corpnames: '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:corpname',
        control_access_genres_forms: '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:genreform',
        control_access_occupations: '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:occupation',
        control_access_persnames: '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:persname',
        control_access_subjects: '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:subject',
        dsc_series: '/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]',
        dsc_series_titles: '/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]/xmlns:did/xmlns:unittitle',
        language: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:langmaterial',
        origination_creators: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:origination[@label="creator"]',
        odd_head: '/xmlns:ead/xmlns:archdesc/xmlns:odd/xmlns:head',
        odd_values: '/xmlns:ead/xmlns:archdesc/xmlns:odd/xmlns:p',
        other_finding_aid_head: '/xmlns:ead/xmlns:archdesc/xmlns:otherfindaid/xmlns:head',
        other_finding_aid_values: '/xmlns:ead/xmlns:archdesc/xmlns:otherfindaid/xmlns:p',
        physical_descriptions: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:physdesc',
        preferred_citation_head: '/xmlns:ead/xmlns:archdesc/xmlns:prefercite/xmlns:head',
        preferred_citation_values: '/xmlns:ead/xmlns:archdesc/xmlns:prefercite/xmlns:p',
        processing_information_head: '/xmlns:ead/xmlns:archdesc/xmlns:processinfo/xmlns:head',
        processing_information_values: '/xmlns:ead/xmlns:archdesc/xmlns:processinfo/xmlns:p',
        publicationstmt_publisher: '/xmlns:ead/xmlns:eadheader/xmlns:filedesc/xmlns:publicationstmt/xmlns:publisher',
        related_material_head: '/xmlns:ead/xmlns:archdesc/xmlns:relatedmaterial/xmlns:head',
        related_material_values: '/xmlns:ead/xmlns:archdesc/xmlns:relatedmaterial/xmlns:p',
        repository_corpname: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:repository/xmlns:corpname',
        revision_description_changes: '/xmlns:ead/xmlns:eadheader/xmlns:revisiondesc/xmlns:change',
        scope_content_head: '/xmlns:ead/xmlns:archdesc/xmlns:scopecontent/xmlns:head',
        scope_content_values: '/xmlns:ead/xmlns:archdesc/xmlns:scopecontent/xmlns:p',
        separated_material_head: '/xmlns:ead/xmlns:archdesc/xmlns:separatedmaterial/xmlns:head',
        separated_material_values: '/xmlns:ead/xmlns:archdesc/xmlns:separatedmaterial/xmlns:p',
        subseries_titles: './xmlns:c[@level="subseries"]/xmlns:did/xmlns:unittitle',
        unit_dates: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:unitdate',
        unit_ids: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:unitid',
        unit_title: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:unittitle',
        use_restrictions_head: '/xmlns:ead/xmlns:archdesc/xmlns:userestrict/xmlns:head',
        use_restrictions_values: '/xmlns:ead/xmlns:archdesc/xmlns:userestrict/xmlns:p'
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
        @publicationstmt_publisher = nokogiri_xml.xpath(XPATH[:publicationstmt_publisher]).text
        revision_description_change_nokogiri_elements =
          nokogiri_xml.xpath(XPATH[:revision_description_changes])
        @revision_description_changes = revision_description_change_nokogiri_elements.map do |change|
          {date: change.xpath('./xmlns:date').text, item: change.xpath('./xmlns:item').text}
        end
      end

      # make private? Makes unit test harder
      def parse_arch_desc_did(nokogiri_xml)
        @abstracts = nokogiri_xml.xpath(XPATH[:abstracts])
        @language = nokogiri_xml.xpath(XPATH[:language]).map(&:text).max_by(&:length)
        @origination_creators = nokogiri_xml.xpath(XPATH[:origination_creators])
        @physical_descriptions = nokogiri_xml.xpath(XPATH[:physical_descriptions])
        @repository_corpname = nokogiri_xml.xpath(XPATH[:repository_corpname]).text
        @unit_dates = nokogiri_xml.xpath(XPATH[:unit_dates])
        @unit_ids = nokogiri_xml.xpath(XPATH[:unit_ids])
        @unit_title = nokogiri_xml.xpath(XPATH[:unit_title]).text
      end

      # make private? Makes unit test harder
      def parse_arch_desc_dsc(nokogiri_xml)
        series_title_nokogiri_elements =
          nokogiri_xml.xpath(XPATH[:dsc_series_titles])
        @dsc_series_titles = series_title_nokogiri_elements.map do |series|
          series.text
        end
        @dsc_series = nokogiri_xml.xpath(XPATH[:dsc_series])
        @subseries_titles = []
        @dsc_series.each do |series|
          @subseries_titles.append series.xpath(XPATH[:subseries_titles]).map(&:text)
        end
      end

      # make private? Makes unit test harder
      def parse_arch_desc_misc(nokogiri_xml)
        @access_restrictions_head = nokogiri_xml.xpath(XPATH[:access_restrictions_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:access_restrictions_head]).first.nil?
        @access_restrictions_values = nokogiri_xml.xpath(XPATH[:access_restrictions_values])
        @accruals_head = nokogiri_xml.xpath(XPATH[:accruals_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:accruals_head]).first.nil?
        @accruals_values = nokogiri_xml.xpath(XPATH[:accruals_values])
        @alternative_form_available_head = nokogiri_xml.xpath(XPATH[:alternative_form_available_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:alternative_form_available_head]).first.nil?
        @alternative_form_available_values = nokogiri_xml.xpath(XPATH[:alternative_form_available_values])
        @arrangement_head = nokogiri_xml.xpath(XPATH[:arrangement_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:arrangement_head]).first.nil?
        @arrangement_values = nokogiri_xml.xpath(XPATH[:arrangement_values])
        @biography_history_head = nokogiri_xml.xpath(XPATH[:biography_history_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:biography_history_head]).first.nil?
        @biography_history_values = nokogiri_xml.xpath(XPATH[:biography_history_values])
        @control_access_corpnames = nokogiri_xml.xpath(XPATH[:control_access_corpnames]).map(&:text)
        @control_access_genres_forms = nokogiri_xml.xpath(XPATH[:control_access_genres_forms]).map(&:text)
        @control_access_occupations = nokogiri_xml.xpath(XPATH[:control_access_occupations]).map(&:text)
        @control_access_persnames = nokogiri_xml.xpath(XPATH[:control_access_persnames]).map(&:text)
        @control_access_subjects = nokogiri_xml.xpath(XPATH[:control_access_subjects]).map(&:text)
        @odd_head = nokogiri_xml.xpath(XPATH[:odd_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:odd_head]).first.nil?
        @odd_values = nokogiri_xml.xpath(XPATH[:odd_values])
        @other_finding_aid_head = nokogiri_xml.xpath(XPATH[:other_finding_aid_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:other_finding_aid_head]).first.nil?
        @other_finding_aid_values = nokogiri_xml.xpath(XPATH[:other_finding_aid_values])
        @preferred_citation_head = nokogiri_xml.xpath(XPATH[:preferred_citation_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:preferred_citation_head]).first.nil?
        @preferred_citation_values = nokogiri_xml.xpath(XPATH[:preferred_citation_values])
        @processing_information_head = nokogiri_xml.xpath(XPATH[:processing_information_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:processing_information_head]).first.nil?
        @processing_information_values = nokogiri_xml.xpath(XPATH[:processing_information_values])
        @related_material_head = nokogiri_xml.xpath(XPATH[:related_material_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:related_material_head]).first.nil?
        @related_material_values = nokogiri_xml.xpath(XPATH[:related_material_values])
        @scope_content_head = nokogiri_xml.xpath(XPATH[:scope_content_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:scope_content_head]).first.nil?
        @scope_content_values = nokogiri_xml.xpath(XPATH[:scope_content_values])
        @separated_material_head = nokogiri_xml.xpath(XPATH[:separated_material_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:separated_material_head]).first.nil?
        @separated_material_values = nokogiri_xml.xpath(XPATH[:separated_material_values])
        @use_restrictions_head = nokogiri_xml.xpath(XPATH[:use_restrictions_head]).first.text unless
          nokogiri_xml.xpath(XPATH[:use_restrictions_head]).first.nil?
        @use_restrictions_values = nokogiri_xml.xpath(XPATH[:use_restrictions_values])
      end

      def series_scope_content_values
        series_nokogiri_elements =
          @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]')
        series_scope_content = series_nokogiri_elements.map do |series|
          series.xpath('./xmlns:scopecontent/xmlns:p')
        end
      end

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
