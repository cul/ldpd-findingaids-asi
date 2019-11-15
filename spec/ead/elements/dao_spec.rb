# Ead::Elements::Dao describes the EAD element <dao>
# Digital Archival Object (https://www.loc.gov/ead/tglib/elements/dao.html)
# and supplies class methods to retrieve pertinent attributes and
# child elements of the <dao> element
require 'rails_helper'
require 'ead/elements/dao'

# Notation note: <a><b> means <b> elements that are direct children of <a>
class_methods = [
  # argument: Nokogiri::XML::Element representing a <dao> element
  # returns: Nokogiri::XML::NodeSet of <daodesc><p>
  # <daodesc> Digital Archival Object Description, <p> Paragraph
  :daodesc_p_node_set,

  # argument: Nokogiri::XML::Element representing a <dao> element
  # returns: Nokogiri::XML::NodeSet containing href attribute of <dao> element
  # href -- The locator for a remote resource in a simple or extended link
  :href_attribute_node_set
].freeze


RSpec.describe Ead::Elements::Dao do
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
      @nokogiri_xml_element = Nokogiri::XML(input_xml).xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c/xmlns:did/xmlns:dao').first
    end

    describe 'class methods:' do
      context 'given argument Nokogiri::XML::Element representing <dao>' do
        it '.daodesc_p_node_set returns correct Nokogiri::XML::NodeSet' do
          value = subject.class.daodesc_p_node_set(@nokogiri_xml_element)
          expect(value).to be_instance_of Nokogiri::XML::NodeSet
          expect(value.text).to eq 'Browse or Search Digital Materials'
        end

        it '.href_attribute_node_set returns correct Nokogiri::XML::NodeSet' do
          value = subject.class.href_attribute_node_set(@nokogiri_xml_element)
          expect(value).to be_instance_of Nokogiri::XML::NodeSet
          expect(value.text).to eq 'https://dlc.library.columbia.edu/ifp/search'
        end
      end
    end
  end
end
