require 'net/http'

module Asi
  class AsEad
    XPATH = {
      archive_abstract: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:abstract',
      archive_access_restrictions_head: '/xmlns:ead/xmlns:archdesc/xmlns:accessrestrict/xmlns:head',
      archive_access_restrictions_value: '/xmlns:ead/xmlns:archdesc/xmlns:accessrestrict/xmlns:p',
      archive_date: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:unitdate',
      archive_dsc_series_titles: '/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]/xmlns:did/xmlns:unittitle',
      archive_id: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:unitid',
      archive_language: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:langmaterial/xmlns:language',
      archive_physical_description_extent_carrier: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:physdesc/xmlns:extent[@altrender="carrier"]',
      archive_preferred_citation_head: '/xmlns:ead/xmlns:archdesc/xmlns:prefercite/xmlns:head',
      archive_preferred_citation_value: '/xmlns:ead/xmlns:archdesc/xmlns:prefercite/xmlns:p',
      archive_processing_information_head: '/xmlns:ead/xmlns:archdesc/xmlns:processinfo/xmlns:head',
      archive_processing_information_value: '/xmlns:ead/xmlns:archdesc/xmlns:processinfo/xmlns:p',
      archive_scope_content_head: '/xmlns:ead/xmlns:archdesc/xmlns:scopecontent/xmlns:head',
      archive_scope_content_value: '/xmlns:ead/xmlns:archdesc/xmlns:scopecontent/xmlns:p',
      archive_repository: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:repository/xmlns:corpname',
      archive_title: '/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:unittitle',
      archive_use_restrictions_head: '/xmlns:ead/xmlns:archdesc/xmlns:userestrict/xmlns:head',
      archive_use_restrictions_value: '/xmlns:ead/xmlns:archdesc/xmlns:userestrict/xmlns:p'
    }

    attr_reader :archive_abstract,
                :archive_access_restrictions_head,
                :archive_access_restrictions_value,
                :archive_date,
                :archive_dsc_series_titles,
                :archive_id,
                :archive_language,
                :archive_physical_description_extent_carrier,
                :archive_preferred_citation_head,
                :archive_preferred_citation_value,
                :archive_processing_information_head,
                :archive_processing_information_value,
                :archive_repository,
                :archive_scope_content_head,
                :archive_scope_content_value,
                :archive_title,
                :archive_use_restrictions_head,
                :archive_use_restrictions_value

    def parse(xml_input)
      # for now, keep it as an attribute instead of a local var
      @nokogiri_xml = Nokogiri::XML(xml_input)
      parse_arch_desc_did(@nokogiri_xml)
      parse_arch_desc_dsc(@nokogiri_xml)
      parse_arch_desc_misc(@nokogiri_xml)
    end

    # make private? Makes unit test harder
    def parse_arch_desc_did(nokogiri_xml)
      @archive_abstract = nokogiri_xml.xpath(XPATH[:archive_abstract]).text
      @archive_date = nokogiri_xml.xpath(XPATH[:archive_date]).text
      @archive_id = nokogiri_xml.xpath(XPATH[:archive_id]).text
      @archive_language = nokogiri_xml.xpath(XPATH[:archive_language]).text
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
    end

    # make private? Makes unit test harder
    def parse_arch_desc_misc(nokogiri_xml)
      @archive_access_restrictions_head = nokogiri_xml.xpath(XPATH[:archive_access_restrictions_head]).first.text unless
        nokogiri_xml.xpath(XPATH[:archive_access_restrictions_head]).first.nil?
      @archive_access_restrictions_value = nokogiri_xml.xpath(XPATH[:archive_access_restrictions_value]).text
      @archive_preferred_citation_head = nokogiri_xml.xpath(XPATH[:archive_preferred_citation_head]).first.text unless
        nokogiri_xml.xpath(XPATH[:archive_preferred_citation_head]).first.nil?
      @archive_preferred_citation_value = nokogiri_xml.xpath(XPATH[:archive_preferred_citation_value]).text
      @archive_processing_information_head = nokogiri_xml.xpath(XPATH[:archive_processing_information_head]).first.text unless
        nokogiri_xml.xpath(XPATH[:archive_processing_information_head]).first.nil?
      @archive_processing_information_value = nokogiri_xml.xpath(XPATH[:archive_processing_information_value]).text
      @archive_scope_content_head = nokogiri_xml.xpath(XPATH[:archive_scope_content_head]).first.text unless
        nokogiri_xml.xpath(XPATH[:archive_scope_content_head]).first.nil?
      @archive_scope_content_value = nokogiri_xml.xpath(XPATH[:archive_scope_content_value]).text
      @archive_use_restrictions_head = nokogiri_xml.xpath(XPATH[:archive_use_restrictions_head]).first.text unless
        nokogiri_xml.xpath(XPATH[:archive_use_restrictions_head]).first.nil?
      @archive_use_restrictions_value = nokogiri_xml.xpath(XPATH[:archive_use_restrictions_value]).text
    end

    def get_creators
      ['Not Present in AS EAD']
      # @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:unitid').text
    end

    def get_series_scope_content
      series_nokogiri_elements =
        @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]')
      series_scope_content = series_nokogiri_elements.map do |series|
        series.xpath('./xmlns:scopecontent/xmlns:p').text
      end
    end

    # May want to split this into multiple methods, one for each element
    def get_subjects
      subject_nokogiri_elements =
        @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:subject' + ' | ' +
                            '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:persname' + ' | ' +
                            '/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:occupation')
      subjects = subject_nokogiri_elements.map do |subject|
        subject.text
      end
    end

    def get_genres_forms
      genre_form_nokogiri_elements =
        @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:controlaccess/xmlns:genreform')
      genres_forms = genre_form_nokogiri_elements.map do |genre_form|
        genre_form.text
      end
    end

    # Note: arg start from 1, but array start at index 0
    def get_files_info_for_series(i)
      series_nokogiri_elements =
        @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]')
      series = series_nokogiri_elements[i-1]
      # puts series.inspect
      series_file_info_nokogiri_elements = series.xpath('./xmlns:c[@level="file"]')
      # puts series_file_info_nokogiri_elements.inspect
      series_files_info = series_file_info_nokogiri_elements.map do |file_info_nokogiri_element|
        title = file_info_nokogiri_element.xpath('./xmlns:did/xmlns:unittitle').text
        box_number = file_info_nokogiri_element.xpath('./xmlns:did/xmlns:container').text
        {title: title, box_number: box_number}
      end
      # puts series_files_info
    end
  end
end
