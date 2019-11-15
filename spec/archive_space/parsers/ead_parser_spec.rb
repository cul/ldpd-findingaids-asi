require 'rails_helper'
require 'archive_space/parsers/ead_parser.rb'

RSpec.describe ArchiveSpace::Parsers::EadParser do
  ########################################## API/interface
  describe 'API/interface' do
    context 'has ' do
      it 'has #parse method' do
        expect(subject.class).to respond_to(:parse).with(1).arguments
      end
    end
  end

  ########################################## Functionality
  describe '-- Validate functionality -- ' do
    before(:context) do
      @xml_input = fixture_file_upload('ead/test_ead.xml').read
    end

    ########################################## parse_arch_desc_misc
    describe 'method .parse' do
      it "sets the stuff correctly" do
        nokogiri_xml_document = subject.class.parse(@xml_input)
        expect(nokogiri_xml_document).to be_instance_of Nokogiri::XML::Document
      end
    end
  end
end
