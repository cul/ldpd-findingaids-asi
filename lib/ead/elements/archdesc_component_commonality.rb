# Following class contains the commonality between the <archdesc> and <c> EAD elements
# <archdesc> Archival Description (https://www.loc.gov/ead/tglib/elements/archdesc.html)
# <c> Component (Unnumbered) (https://www.loc.gov/ead/tglib/elements/c.html)
# and supplies class methods to retrieve pertinent child elements of the
# above elements

# Notation note: <a><b> means <b> elements that are direct children of <a>

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
        controlaccess: './xmlns:controlaccess',
        custodhist_head: './xmlns:custodhist/xmlns:head',
        custodhist_p: './xmlns:custodhist/xmlns:p',
        did: './xmlns:did',
        dsc: './xmlns:dsc',
        level_attribute: './@level',
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
        # returns: Nokogiri::XML::NodeSet of <accessrestrict><head>
        def accessrestrict_head_node_set(input_element)
          input_element.xpath(XPATH[:accessrestrict_head])
        end

        # returns: Nokogiri::XML::NodeSet of <accessrestrict><p>
        def accessrestrict_p_node_set(input_element)
          input_element.xpath(XPATH[:accessrestrict_p])
        end

        # returns: Nokogiri::XML::NodeSet of  <accruals><head>
        def accruals_head_node_set(input_element)
          input_element.xpath(XPATH[:accruals_head])
        end

        # returns: Nokogiri::XML::NodeSet of <accruals><p>
        def accruals_p_node_set(input_element)
          input_element.xpath(XPATH[:accruals_p])
        end

        # returns: Nokogiri::XML::NodeSet of <acqinfo><head>
        def acqinfo_head_node_set(input_element)
          input_element.xpath(XPATH[:acqinfo_head])
        end

        # returns: Nokogiri::XML::NodeSet of <acqinfo><p>
        def acqinfo_p_node_set(input_element)
          input_element.xpath(XPATH[:acqinfo_p])
        end

        # returns: Nokogiri::XML::NodeSet of <altformavail><head>
        def altformavail_head_node_set(input_element)
          input_element.xpath(XPATH[:altformavail_head])
        end

        # returns: Nokogiri::XML::NodeSet of <altformavail><p>
        def altformavail_p_node_set(input_element)
          input_element.xpath(XPATH[:altformavail_p])
        end

        # returns: Nokogiri::XML::NodeSet of <arrangement><head>
        def arrangement_head_node_set(input_element)
          input_element.xpath(XPATH[:arrangement_head])
        end

        # returns: Nokogiri::XML::NodeSet of <arrangement><p>
        def arrangement_p_node_set(input_element)
          input_element.xpath(XPATH[:arrangement_p])
        end

        # returns: Nokogiri::XML::NodeSet of <bioghist><head>
        def bioghist_head_node_set(input_element)
          input_element.xpath(XPATH[:bioghist_head])
        end

        # returns: Nokogiri::XML::NodeSet of <bioghist><p>
        def bioghist_p_node_set(input_element)
          input_element.xpath(XPATH[:bioghist_p])
        end

        # returns: Nokogiri::XML::NodeSet of <controlaccess>
        def controlaccess_node_set(input_element)
          input_element.xpath(XPATH[:controlaccess])
        end

        # returns: Nokogiri::XML::NodeSet of <custodhist><head>
        def custodhist_head_node_set(input_element)
          input_element.xpath(XPATH[:custodhist_head])
        end

        # returns: Nokogiri::XML::NodeSet of <custodhist><p>
        def custodhist_p_node_set(input_element)
          input_element.xpath(XPATH[:custodhist_p])
        end

        # returns: Nokogiri::XML::NodeSet of <did>
        def did_node_set(input_element)
          input_element.xpath(XPATH[:did])
        end

        # returns: Nokogiri::XML::NodeSet of <dsc>
        def dsc_node_set(input_element)
          input_element.xpath(XPATH[:dsc])
        end

        # returns: Nokogiri::XML::NodeSet of level attribute of <c>
        def level_attribute_node_set(input_element)
          input_element.xpath(XPATH[:level_attribute])
        end

        # returns: Nokogiri::XML::NodeSet of <odd><head>
        def odd_head_node_set(input_element)
          input_element.xpath(XPATH[:odd_head])
        end

        # returns: Nokogiri::XML::NodeSet of <odd><p>
        def odd_p_node_set(input_element)
          input_element.xpath(XPATH[:odd_p])
        end

        # returns: Nokogiri::XML::NodeSet of <otherfindaid><head>
        def otherfindaid_head_node_set(input_element)
          input_element.xpath(XPATH[:otherfindaid_head])
        end

        # returns: Nokogiri::XML::NodeSet of <otherfindaid><p>
        def otherfindaid_p_node_set(input_element)
          input_element.xpath(XPATH[:otherfindaid_p])
        end

        # returns: Nokogiri::XML::NodeSet of <prefercite><head>
        def prefercite_head_node_set(input_element)
          input_element.xpath(XPATH[:prefercite_head])
        end

        # returns: Nokogiri::XML::NodeSet of <prefercite><p>
        def prefercite_p_node_set(input_element)
          input_element.xpath(XPATH[:prefercite_p])
        end

        # returns: Nokogiri::XML::NodeSet of <processinfo><head>
        def processinfo_head_node_set(input_element)
          input_element.xpath(XPATH[:processinfo_head])
        end

        # returns: Nokogiri::XML::NodeSet of <processinfo><p>
        def processinfo_p_node_set(input_element)
          input_element.xpath(XPATH[:processinfo_p])
        end

        # returns: Nokogiri::XML::NodeSet of <relatedmaterial><head>
        def relatedmaterial_head_node_set(input_element)
          input_element.xpath(XPATH[:relatedmaterial_head])
        end

        # returns: Nokogiri::XML::NodeSet of <relatedmaterial><p>
        def relatedmaterial_p_node_set(input_element)
          input_element.xpath(XPATH[:relatedmaterial_p])
        end

        # returns: Nokogiri::XML::NodeSet of <scopecontent><head>
        def scopecontent_head_node_set(input_element)
          input_element.xpath(XPATH[:scopecontent_head])
        end

        # returns: Nokogiri::XML::NodeSet of <scopecontent><p>
        def scopecontent_p_node_set(input_element)
          input_element.xpath(XPATH[:scopecontent_p])
        end

        # returns: Nokogiri::XML::NodeSet of <separatedmaterial><head>
        def separatedmaterial_head_node_set(input_element)
          input_element.xpath(XPATH[:separatedmaterial_head])
        end

        # returns: Nokogiri::XML::NodeSet of <separatedmaterial><p>
        def separatedmaterial_p_node_set(input_element)
          input_element.xpath(XPATH[:separatedmaterial_p])
        end

        # returns: Nokogiri::XML::NodeSet of <userestrict><head>
        def userestrict_head_node_set(input_element)
          input_element.xpath(XPATH[:userestrict_head])
        end

        # returns: Nokogiri::XML::NodeSet of <userestrict><p>
        def userestrict_p_node_set(input_element)
          input_element.xpath(XPATH[:userestrict_p])
        end
      end
    end
  end
end
