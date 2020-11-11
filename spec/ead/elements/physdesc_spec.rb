require 'rails_helper'
require 'ead/elements/physdesc.rb'

class_methods = [
  :extent_node_set, # <extent> Extent
  :physfacet_node_set # <physfacet> Physical Facet
].freeze


RSpec.describe Ead::Elements::Physdesc do
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
      @nokogiri_node_set = Nokogiri::XML(input_xml).xpath('/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:physdesc')
      # @input_xml = fixture_file_upload('ead/test_ead.xml').read
    end

    describe 'class methods:' do
      context 'given as argument a <physdesc> containing two <extent>' do
        it '.extent_node_set class method returns correct information' do
          value = Ead::Elements::Physdesc.extent_node_set(@nokogiri_node_set.first)[0]
          expect(value.text).to eq '3 linear feet'
        end
        it '.extent_node_set class method returns correct information' do
          value = Ead::Elements::Physdesc.extent_node_set(@nokogiri_node_set.first)[1]
          expect(value.text).to eq '4 boxes 13 slipcases'
        end
      end
      context 'given as argument a <physdesc> containing one <extent>' do
        it '.extent_node_set class method returns correct information' do
          value = Ead::Elements::Physdesc.extent_node_set(@nokogiri_node_set[1]).first
          expect(value.text).to eq '2 open reel audiotapes'
        end
      end
      context 'given as argument a <physdesc> containing one <physfacet>' do
        it '.physfacet_node_set class method returns correct information' do
          value = Ead::Elements::Physdesc.physfacet_node_set(@nokogiri_node_set[2]).first
          expect(value.text).to eq '7.5 inches per second'
        end
      end
    end
  end
end
