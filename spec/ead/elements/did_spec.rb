# Ead::Elements::Did describes the EAD element <did>
# Descriptive Identification (https://www.loc.gov/ead/tglib/elements/did.html)
# and supplies class methods to retrieve pertinent child elements
# of the <did> element
require 'rails_helper'
require 'ead/elements/did.rb'

class_methods = [
  :abstract_node_set, # <abstract> Abstract
  :container_node_set, # <container> Container
  :dao_node_set, # <dao> Digital Archival Object
  :langmaterial_node_set, # <langmaterial> Language of the Material
  :origination_label_attribute_creator_node_set, # <origination> Origination, <origination label="creator">
  :physdesc_node_set, # <physdesc> Physical Description
  :repository_corpname_node_set, # <repository> Repository, <corpname> Corporate Name
  :unitdate_node_set, # <unitdate> Date of the Unit
  :unitid_node_set, # <unitid> ID of the Unit
  :unittitle_node_set # <unittitle> Title of the Unit
].freeze

# following is a subset of the above array
class_methods_tested_individually = [
  :dao_node_set
].freeze

RSpec.describe Ead::Elements::Did do
  ########################################## API/interface
  describe '-- Validate API/interface --' do
    context 'has class method' do
      class_methods.each do |class_method|
        it "#{class_method}" do
          expect(subject.class).to respond_to("#{class_method}")
        end
      end
    end
  end  

  ########################################## Functionality
  describe '-- Validate functionality --' do
    before(:context) do
      input_xml = fixture_file_upload('ead/test_ead.xml').read
      nokogiri_document = Nokogiri::XML(input_xml)
      @nokogiri_node_set = Nokogiri::XML(input_xml).xpath('/xmlns:ead/xmlns:archdesc/xmlns:did')
    end

    describe ' class methods that return an array:' do
      context 'class method' do
        # <abstract> Abstract
        let (:expected_abstract_node_set) {
          [
            "This collection is made up of architectural drawings."
          ]
        }

        # <container> Container
        let (:expected_container_node_set) {
          [
            '78',
            '5'
          ]
        }

        # <dao><daodesc><p>
        let (:expected_dao_daodesc_p_values) {
          [
            "Image logo for the collection",
            "CUL logo"
          ]
        }

        # <langmaterial> Language of the Material
        let (:expected_langmaterial_node_set) {
          [
            "English",
            "Dutch",
            "Material is in English and in French, with some materials in Dutch."
          ]
        }

        # <origination> Origination, <origination label="creator">
        let (:expected_origination_label_attribute_creator_node_set) {
          [
            "Columbia University. Teachers College",
            "Romanov family",
            "Sassoon, Siegfried, 1886-1967"
          ]
        }

        # <physdesc> Physical Description
        # <extent> Extent
        # <exten> is a <physdesc> subelement for information about the quantity of the materials
        # being described or an expression of the physical space they occupy
        let (:expected_physdesc_node_set) {
          [
            "3 linear feet 4 boxes 13 slipcases",
            "3.6 Tb Digital one hard disk",
            "423 linear feet 351 record cartons 15 document boxes and 4 flat boxes"
          ]
        }

        # <repository> Repository, <corpname> Corporate Name
        let (:expected_repository_corpname_node_set) {
          [
            'Rare Book and Manuscript Library'
          ]
        }

        # <unitdate> Date of the Unit
        let (:expected_unitdate_node_set) {
          [
            '1914-1989',
            '1958-1980',
            '1894-1966'
          ]
        }

        # <unitid> ID of the Unit
        let (:expected_unitid_node_set) {
          [
            '4079591',
            'MS#0030'
          ]
        }

        # <unittitle> Title of the Unit
        let (:expected_unittitle_node_set) {
          [
            'Siegfried Sassoon papers'
          ]
        }

        # Testing .dao_node_set
        it '.dao_node_set takes a <did> element and returns an Nokogiri::XML::NodeSet of <dao> elements' do
          dao_node_set = Ead::Elements::Did.dao_node_set(@nokogiri_node_set)
          expect(dao_node_set.size).to eq expected_dao_daodesc_p_values.size
          expected_dao_daodesc_p_values.each_with_index do |expected_dao_desc_p_value, index|
            expect(dao_node_set[index].xpath('./xmlns:daodesc/xmlns:p').text).to eq expected_dao_desc_p_value
          end
        end

        # NOTE: Testing the class methods listed the class_methods_tested_individually array is more involved, so the functionality
        # is not tested in the following example. Instead, the functionality for these class methods is tested in separate examples
        (class_methods - class_methods_tested_individually).each do |class_method|
          it ".#{class_method} takes a <did> and returns an array of <#{class_method.to_s.chomp('_node_set')}>" do
            values = Ead::Elements::Did.send(class_method,@nokogiri_node_set)
            expected_values = eval "expected_#{class_method}"
            expected_values.each_with_index do |expected_value, index|
              expect(values[index].text.squish).to eq expected_value
            end
          end
        end
      end
    end
  end
end
