require 'rails_helper'
require 'ead/elements/extent.rb'

class_methods = [
  :altrender_attribute_node_set
].freeze


RSpec.describe Ead::Elements::Extent do
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
      input_xml = fixture_file_upload('ead/test_physdesc.xml').read
      nokogiri_document = Nokogiri::XML(input_xml)
      physdesc_nokogiri_node_set = Nokogiri::XML(input_xml).xpath('/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:physdesc').first
      @nokogiri_node_set = physdesc_nokogiri_node_set.xpath('./xmlns:extent')
    end
    describe 'class methods:' do
      context 'given <extent> as argument' do
        it '.altrender_attribute_node_set class method returns correct information' do
          value = Ead::Elements::Extent.altrender_attribute_node_set(@nokogiri_node_set.first).text
          expect(value).to eq 'materialtype spaceoccupied'
        end
        it '.altrender_attribute_node_set class method returns correct information' do
          value = Ead::Elements::Extent.altrender_attribute_node_set(@nokogiri_node_set[1]).text
          expect(value).to eq 'carrier'
        end
      end
    end
  end
end
