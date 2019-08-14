require 'rails_helper'
require 'archive_space/ead/did.rb'

attributes = [
  :unit_dates, # <did>:<unitdate>
  :unit_title # <did>:<unititle>
].freeze


RSpec.describe ArchiveSpace::Ead::Did do
  ########################################## API/interface
  describe 'API/interface' do
    context 'has' do
      it 'unit_dates class method that takes one argument' do
        expect(subject.class).to respond_to(:unit_dates).with(1).argument
      end
    end

    context 'has' do
      it 'unit_title class method that takes one argument' do
        expect(subject.class).to respond_to(:unit_titles).with(1).argument
      end
    end
  end

  ########################################## Functionality
  describe 'Testing functionality' do
    before(:context) do
      input_xml = fixture_file_upload('asi/did.xml').read
      nokogiri_document = Nokogiri::XML(input_xml)
      # puts nokogiri_document.inspect
      @nokogiri_node_set = Nokogiri::XML(input_xml).xpath('/xmlns:ead/xmlns:archdesc')
      # puts @nokogiri_node_set.inspect
      # @as_ead = ArchiveSpace::Ead::EadParser.new xml_input
    end

    context 'unit_dates' do
      it 'takes an EAD element containg a <did> (an <archdesc> in this case) and returns the dates' do
        dates = ArchiveSpace::Ead::Did.unit_dates(@nokogiri_node_set)
        puts dates.inspect
      end
    end
  end
end
