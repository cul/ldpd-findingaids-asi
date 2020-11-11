require 'rails_helper'
require 'archive_space/parsers/ead_helper.rb'

class_methods = [
  :compound_title,
  :component_physical_descriptions_string
].freeze


RSpec.describe ArchiveSpace::Parsers::EadHelper do
  ########################################## API/interface
  describe '-- Validate API/interface --' do
    context 'has class method' do
      class_methods.each do |class_method|
        xit "#{class_method}" do
          expect(subject.class).to respond_to("#{class_method}")
        end
      end
    end
  end

  ########################################## Functionality
  describe '-- Validate functionality --' do
    before(:context) do
      input_xml = fixture_file_upload('ead/test_physdesc.xml').read
      @nokogiri_node_set = Nokogiri::XML(input_xml).xpath('/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:physdesc')
    end
    let (:expected_phys_desc_string) {
      ['3 linear feet', '4 boxes 13 slipcases', '2 open reel audiotapes', '7.5 inches per second',
       '(typescript)', '1 audiocassettes', '1 videotape', 'Umatic tape'].join('; ')
    }
    describe 'class methods:' do
      context 'given as argument a set of <physdesc>' do
        it '.component_physical_descriptions_string class method returns correct information' do
          value = ArchiveSpace::Parsers::EadHelper.component_physical_descriptions_string(@nokogiri_node_set)
          expect(value).to eq expected_phys_desc_string
        end
      end
    end
  end
end
