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
        appraisal_head: './xmlns:appraisal/xmlns:head',
        appraisal_p: './xmlns:appraisal/xmlns:p',
        arrangement_head: './xmlns:arrangement/xmlns:head',
        arrangement_p: './xmlns:arrangement/xmlns:p',
        bibliography: './xmlns:bibliography',
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

        # returns: Nokogiri::XML::NodeSet of <appraisal><head>
        def appraisal_head_node_set(input_element)
          input_element.xpath(XPATH[:appraisal_head])
        end

        # returns: Nokogiri::XML::NodeSet of <appraisal><p>
        def appraisal_p_node_set(input_element)
          input_element.xpath(XPATH[:appraisal_p])
        end

        # returns: Nokogiri::XML::NodeSet of <arrangement><head>
        def arrangement_head_node_set(input_element)
          input_element.xpath(XPATH[:arrangement_head])
        end

        # returns: Nokogiri::XML::NodeSet of <arrangement><p>
        def arrangement_p_node_set(input_element)
          input_element.xpath(XPATH[:arrangement_p])
        end

        # returns: Nokogiri::XML::NodeSet of <bibliography>
        def bibliography_node_set(input_element)
          input_element.xpath(XPATH[:bibliography])
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

      attr_reader :nokogiri_element

      def initialize(nokogiri_element)
        reset! nokogiri_element
      end

      def reset!(nokogiri_element = nil)
        @nokogiri_element = nokogiri_element
      end

      XPATH.keys.each do |node_type|
        define_method "#{node_type}_node_set" do
          self.class.send :"#{node_type}_node_set", nokogiri_element
        end
      end
      alias_method :acquisition_information_values, :acqinfo_p_node_set
      alias_method :alternative_form_available_values, :altformavail_p_node_set
      alias_method :arrangement_values, :arrangement_p_node_set
      alias_method :biography_or_history_values, :bioghist_p_node_set
      alias_method :conditions_governing_access_values, :accessrestrict_p_node_set
      alias_method :conditions_governing_use_values, :userestrict_p_node_set
      alias_method :custodial_history_values, :custodhist_p_node_set
      alias_method :other_descriptive_data_values, :odd_p_node_set
      alias_method :other_finding_aid_values, :otherfindaid_p_node_set
      alias_method :related_material_values, :relatedmaterial_p_node_set
      alias_method :scope_and_content_values, :scopecontent_p_node_set
      alias_method :separated_material_values, :separatedmaterial_p_node_set

      def acquisition_information_head
        acqinfo_head_node_set.first&.text
      end

      def alternative_form_available_head
        altformavail_head_node_set.first&.text
      end

      def arrangement_head
        arrangement_head_node_set.first&.text
      end

      def biography_or_history_head
        bioghist_head_node_set.first&.text
      end

      def compound_title_string
        ArchiveSpace::Parsers::EadHelper.compound_title nokogiri_element
      end

      def conditions_governing_access_head
        accessrestrict_head_node_set.first&.text
      end

      def conditions_governing_use_head
        userestrict_head_node_set.first&.text
      end

      def custodial_history_head
        custodhist_head_node_set.first&.text
      end

      def level_attribute
        level_attribute_node_set.first&.text
      end

      def other_descriptive_data_head
        odd_head_node_set.first&.text
      end

      def other_finding_aid_head
        otherfindaid_head_node_set.first&.text
      end

      def related_material_head
        relatedmaterial_head_node_set.first&.text
      end

      def scope_and_content_head
        scopecontent_head_node_set.first&.text
      end

      def separated_material_head
        separatedmaterial_head_node_set.first&.text
      end
    end
  end
end
