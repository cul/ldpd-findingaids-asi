# Following class describes the Encoded Archival Description (EAD) element:
# <archdesc> Archival Description
# EAD specs: https://www.loc.gov/ead/index.html
#
# It supplies class methods to access the following children:
# <accessrestrict> Conditions Governing Access
# <accruals> Accruals
# <altformavail> Alternative Form Available
# <did> Descriptive Identification
# <dsc> Description of Subordinate Components

module Ead
  module Elements
    class ArchdescComponentCommonality
      XPATH = {
        accessrestrict_head: './xmlns:accessrestrict/xmlns:head',
        accessrestrict_p: './xmlns:accessrestrict/xmlns:p',
        accruals_head: './xmlns:accruals/xmlns:head',
        accruals_p: './xmlns:accruals/xmlns:p',
        acqinfo_head: './xmlns:acqinfo/xmlns:head',
        acqinfo_p: './xmlns:acqinfo/xmlns:p',
        altformavail_head: './xmlns:altformavail/xmlns:head',
        altformavail_p: './xmlns:altformavail/xmlns:p',
        arrangement_head: './xmlns:arrangement/xmlns:head',
        arrangement_p: './xmlns:arrangement/xmlns:p',
        bioghist_head: './xmlns:bioghist/xmlns:head',
        bioghist_p: './xmlns:bioghist/xmlns:p',
        controlaccess_array: './xmlns:controlaccess',
        did: './xmlns:did',
        dsc: './xmlns:dsc',
        odd_head: './xmlns:odd/xmlns:head',
        odd_p: './xmlns:odd/xmlns:p',
        otherfindaid_head: './xmlns:otherfindaid/xmlns:head',
        otherfindaid_p: './xmlns:otherfindaid/xmlns:p',
        prefercite_head: './xmlns:prefercite/xmlns:head',
        prefercite_p: './xmlns:prefercite/xmlns:p',
        processinfo_head: './xmlns:processinfo/xmlns:head',
        processinfo_p: './xmlns:processinfo/xmlns:p',
        relatedmaterial_head: './xmlns:relatedmaterial/xmlns:head',
        relatedmaterial_p: './xmlns:relatedmaterial/xmlns:p',
        scopecontent_head: './xmlns:scopecontent/xmlns:head',
        scopecontent_p: './xmlns:scopecontent/xmlns:p',
        separatedmaterial_head: './xmlns:separatedmaterial/xmlns:head',
        separatedmaterial_p: './xmlns:separatedmaterial/xmlns:p',
        userestrict_head: './xmlns:userestrict/xmlns:head',
        userestrict_p: './xmlns:userestrict/xmlns:p'
      }.freeze

      class << self
        # returns: value of the first <accessrestrict><head>
        def accessrestrict_head_array(input_element)
          input_element.xpath(XPATH[:accessrestrict_head])
        end

        # returns: array of  Nokogiri::XML::Element instances for <accessrestrict><p>
        def accessrestrict_p_array(input_element)
          input_element.xpath(XPATH[:accessrestrict_p])
        end

        # returns: value of the first <accruals><head>
        def accruals_head_array(input_element)
          input_element.xpath(XPATH[:accruals_head])
        end

        # returns: array of  Nokogiri::XML::Element instances for <accruals><p>
        def accruals_p_array(input_element)
          input_element.xpath(XPATH[:accruals_p])
        end

        # returns: value of the first <acqinfo><head>
        def acqinfo_head_array(input_element)
          input_element.xpath(XPATH[:acqinfo_head])
        end

        # returns: array of  Nokogiri::XML::Element instances for <acqinfo><p>
        def acqinfo_p_array(input_element)
          input_element.xpath(XPATH[:acqinfo_p])
        end

        # returns: value of the first <altformavail><head>
        def altformavail_head_array(input_element)
          input_element.xpath(XPATH[:altformavail_head])
        end

        # returns: array of  Nokogiri::XML::Element instances for <altformavail><p>
        def altformavail_p_array(input_element)
          input_element.xpath(XPATH[:altformavail_p])
        end

        # returns: value of the first <arrangement><head>
        def arrangement_head_array(input_element)
          input_element.xpath(XPATH[:arrangement_head])
        end

        # returns: array of  Nokogiri::XML::Element instances for <arrangement><p>
        def arrangement_p_array(input_element)
          input_element.xpath(XPATH[:arrangement_p])
        end

        # returns: value of the first <bioghist><head>
        def bioghist_head_array(input_element)
          input_element.xpath(XPATH[:bioghist_head])
        end

        # returns: array of  Nokogiri::XML::Element instances for <bioghist><p>
        def bioghist_p_array(input_element)
          input_element.xpath(XPATH[:bioghist_p])
        end

        # returns: array of  Nokogiri::XML::Element instances for <controlaccess>
        def controlaccess_array(input_element)
          input_element.xpath(XPATH[:controlaccess_array])
        end

        # returns: Nokogiri::XML::Element instance for <did>
        # ASSUMPTION: one one child <did> in an element, so return the first element
        # in the array of Nokogiri::XML::Element
        def did(input_element)
          input_element.xpath(XPATH[:did]).first
        end

        # returns: Nokogiri::XML::Element instance for <dsc>
        # ASSUMPTION: one one child <dsc> in an element, so return the first element
        # in the array of Nokogiri::XML::Element
        def dsc(input_element)
          input_element.xpath(XPATH[:dsc]).first
        end

        # returns: value of the first <odd><head>
        def odd_head_array(input_element)
          input_element.xpath(XPATH[:odd_head])
        end

        # returns: array of  Nokogiri::XML::Element instances for <odd><p>
        def odd_p_array(input_element)
          input_element.xpath(XPATH[:odd_p])
        end

        # returns: value of the first <otherfindaid><head>
        def otherfindaid_head_array(input_element)
          input_element.xpath(XPATH[:otherfindaid_head])
        end

        # returns: array of  Nokogiri::XML::Element instances for <otherfindaid><p>
        def otherfindaid_p_array(input_element)
          input_element.xpath(XPATH[:otherfindaid_p])
        end

        # returns: value of the first <prefercite><head>
        def prefercite_head_array(input_element)
          input_element.xpath(XPATH[:prefercite_head])
        end

        # returns: array of  Nokogiri::XML::Element instances for <prefercite><p>
        def prefercite_p_array(input_element)
          input_element.xpath(XPATH[:prefercite_p])
        end

        # returns: value of the first <processinfo><head>
        def processinfo_head_array(input_element)
          input_element.xpath(XPATH[:processinfo_head])
        end

        # returns: array of  Nokogiri::XML::Element instances for <processinfo><p>
        def processinfo_p_array(input_element)
          input_element.xpath(XPATH[:processinfo_p])
        end

        # returns: value of the first <relatedmaterial><head>
        def relatedmaterial_head_array(input_element)
          input_element.xpath(XPATH[:relatedmaterial_head])
        end

        # returns: array of  Nokogiri::XML::Element instances for <relatedmaterial><p>
        def relatedmaterial_p_array(input_element)
          input_element.xpath(XPATH[:relatedmaterial_p])
        end

        # returns: value of the first <scopecontent><head>
        def scopecontent_head_array(input_element)
          input_element.xpath(XPATH[:scopecontent_head])
        end

        # returns: array of  Nokogiri::XML::Element instances for <scopecontent><p>
        def scopecontent_p_array(input_element)
          input_element.xpath(XPATH[:scopecontent_p])
        end

        # returns: value of the first <separatedmaterial><head>
        def separatedmaterial_head_array(input_element)
          input_element.xpath(XPATH[:separatedmaterial_head])
        end

        # returns: array of  Nokogiri::XML::Element instances for <separatedmaterial><p>
        def separatedmaterial_p_array(input_element)
          input_element.xpath(XPATH[:separatedmaterial_p])
        end

        # returns: value of the first <userestrict><head>
        def userestrict_head_array(input_element)
          input_element.xpath(XPATH[:userestrict_head])
        end

        # returns: array of  Nokogiri::XML::Element instances for <userestrict><p>
        def userestrict_p_array(input_element)
          input_element.xpath(XPATH[:userestrict_p])
        end
      end
    end
  end
end
