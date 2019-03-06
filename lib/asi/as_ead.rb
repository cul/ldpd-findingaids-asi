require 'net/http'

module Asi
  class AsEad
    def parse(xml_input)
      @nokogiri_xml = Nokogiri::XML(xml_input)
    end

    def get_ead_title
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:unittitle').text
    end

    def get_ead_abstract
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:abstract').text
    end

    def get_bib_id
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:unitid').text
    end

    def get_creators
      ['Not Present in AS EAD']
      # @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:unitid').text
    end

    def get_unit_date
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:unitdate').text
    end

    def get_physical_description_extent
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:physdesc/xmlns:extent[@altrender="carrier"]').text
    end

    def get_lang_material
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:langmaterial/xmlns:language').text
    end

    def get_access_restrictions_head
      # Need to use first for now
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:accessrestrict/xmlns:head').first.text
    end

    def get_access_restrictions_value
      # Need to use first for now
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:accessrestrict/xmlns:p').first.text
    end

    def get_series_titles
      series_title_nokogiri_elements =
        @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]/xmlns:did/xmlns:unittitle')
      series_titles = series_title_nokogiri_elements.map do |series|
        series.text
      end
    end

    def get_scope_content_head
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:scopecontent/xmlns:head').text
    end

    def get_scope_content_value
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:scopecontent/xmlns:p').text
    end

    def get_series_scope_content
      series_nokogiri_elements =
        @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]')
      series_scope_content = series_nokogiri_elements.map do |series|
        series.xpath('./xmlns:scopecontent/xmlns:p').text
      end
    end

    def get_repository_corpname
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:repository/xmlns:corpname').text
    end

    def get_prefer_cite_head
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:prefercite/xmlns:head').text
    end

    def get_prefer_cite_value
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:prefercite/xmlns:p').text
    end

    def get_use_restrict_head
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:userestrict/xmlns:head').text
    end

    def get_use_restrict_value
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:userestrict/xmlns:p').text
    end

    def get_process_info_head
      # Only return the first instance, assume all are the same.
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:processinfo/xmlns:head').first.text
    end

    def get_process_info_value
      @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:processinfo/xmlns:p').text
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
