require 'rails_helper'
require 'ead/elements/eadheader.rb'

class_methods = [
  # Info pertinent to filedesc_publicationstmt_publisher method:
  # <filedesc> File Description, <publicationstmt> Publication Statement, <publisher> Publisher
  # <publicationstmt> is not repeatable
  :filedesc_publicationstmt_publisher_node_set, # <filedesc><publicationstmt><publisher>
  :revisiondesc_change_node_set # <revisiondesc><change>
].freeze


RSpec.describe Ead::Elements::Eadheader do
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
      # Retrieve the <eadheader> element used for testing:
      @eadheader_nokogiri_element = Nokogiri::XML(input_xml).xpath('/xmlns:ead/xmlns:eadheader')
    end

    describe ' class methods:' do
      context 'Given a Nokogiri::Node::Set representing an <eadheader> element as an argument, class method' do
        it '.filedesc_publicationstmt_publisher returns an Nokogiri::XML::Element instance representing the retrieved <publisher> element' do
          retrieved_value = subject.class.filedesc_publicationstmt_publisher_node_set(@eadheader_nokogiri_element).first.text
          expect(retrieved_value).to eq 'Avery Architectural and Fine Arts Library'
        end

        it '.revisiondesc_change_array returns an array of Nokogiri::XML::Element instances representing the retrieved <change> element(s)' do
          retrieved_values = subject.class.revisiondesc_change_node_set(@eadheader_nokogiri_element)
          expect(retrieved_values[0].xpath('./xmlns:date').text).to eq '2015-02-28'
          expect(retrieved_values[0].xpath('./xmlns:item').text).to eq 'File created.'
          expect(retrieved_values[1].xpath('./xmlns:date').text).to eq '2019-05-20'
          expect(retrieved_values[1].xpath('./xmlns:item').text).to eq 'EAD was imported spring 2019 as part of the ArchivesSpace Phase II migration.'
        end
      end
    end
  end
end
