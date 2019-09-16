require 'rails_helper'
require 'ead/elements/container.rb'

class_methods = [
  :label_attribute,
  :type_attribute
].freeze


RSpec.describe Ead::Elements::Container do
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
      @nokogiri_node_set = Nokogiri::XML(input_xml).xpath('/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:container').first
    end

    describe 'class methods:' do
      context 'given <container> as argument' do
        it '.label_attribute_node_set class method return correct information' do
          value = Ead::Elements::Container.label_attribute(@nokogiri_node_set)
          expect(value.text).to eq 'general envelopes box'
        end

        it '.type_attribute_node_set class method return correct information' do
          value = Ead::Elements::Container.type_attribute(@nokogiri_node_set)
          expect(value.text).to eq 'envelope'
        end
      end
    end
  end
end
