require 'rails_helper'
require 'ead/elements/change.rb'

class_methods = [
  :date_node_set, # <date> Date
  :item_node_set # <item> Item
].freeze


RSpec.describe Ead::Elements::Change do
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
      @nokogiri_xml_element = Nokogiri::XML(input_xml).xpath('/xmlns:ead/xmlns:eadheader/xmlns:revisiondesc/xmlns:change').first
    end

    describe 'class methods:' do
      context 'given <change> as argument' do
        it '.date_node_set class method return correct information' do
          value = Ead::Elements::Change.date_node_set(@nokogiri_xml_element)
          expect(value.text).to eq '2015-02-28'
        end
      end

      context 'given <change> as argument' do
        it '.item_node_set class method return correct information' do
          value = Ead::Elements::Change.item_node_set(@nokogiri_xml_element)
          expect(value.text).to eq 'File created.'
        end
      end
    end
  end
end
