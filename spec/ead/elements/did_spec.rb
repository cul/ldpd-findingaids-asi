require 'rails_helper'
require 'ead/elements/did.rb'

class_methods = [
  :abstract_array, # <abstract> Abstract
  :langmaterial_array, # <langmaterial> Language of the Material
  :origination_label_attribute_creator_array, # <origination> Origination, <origination label="creator">
  :physdesc_array, # <physdesc> Physical Description
  :repository_corpname_array, # <repository> Repository, <corpname> Corporate Name
  :unitdate_array, # <unitdate> Date of the Unit
  :unitid_array, # <unitid> ID of the Unit
  :unittitle_array # <unittitle> Title of the Unit
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
        let (:expected_abstract_array) {
          [
            "This collection is made up of architectural drawings."
          ]
        }

        # <langmaterial> Language of the Material
        let (:expected_langmaterial_array) {
          [
            "English",
            "Dutch",
            "Material is in English and in French, with some materials in Dutch."
          ]
        }

        # <origination> Origination, <origination label="creator">
        let (:expected_origination_label_attribute_creator_array) {
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
        let (:expected_physdesc_array) {
          [
            "3 linear feet 4 boxes 13 slipcases",
            "3.6 Tb Digital one hard disk",
            "423 linear feet 351 record cartons 15 document boxes and 4 flat boxes"
          ]
        }

        # <repository> Repository, <corpname> Corporate Name
        let (:expected_repository_corpname_array) {
          [
            'Rare Book and Manuscript Library'
          ]
        }

        # <unitdate> Date of the Unit
        let (:expected_unitdate_array) {
          [
            '1914-1989',
            '1958-1980',
            '1894-1966'
          ]
        }

        # <unitid> ID of the Unit
        let (:expected_unitid_array) {
          [
            '4079591',
            'MS#0030'
          ]
        }

        # <unittitle> Title of the Unit
        let (:expected_unittitle_array) {
          [
            'Siegfried Sassoon papers'
          ]
        }

        array_class_methods = class_methods.find_all { |class_method| "#{class_method}".ends_with? "_array"}
        array_class_methods.each do |class_method|
          it ".#{class_method} takes a <did> and returns an array of <#{class_method.to_s.chomp('_array')}>" do
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
