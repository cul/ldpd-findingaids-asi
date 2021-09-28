require 'rails_helper'
require 'ead/elements/bibliography.rb'

class_methods = [
  :head_node_set, # <head> Heading
  :bibref_title_node_set, # <bibref><title> <bibref> Bibliographic Reference <title> Title
  :p_node_set # <p> Paragraph
].freeze


RSpec.describe Ead::Elements::Bibliography do
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
      input_xml = fixture_file_upload('ead/test_bibliography.xml').read
      @nokogiri_node_set = Nokogiri::XML(input_xml).xpath('/xmlns:ead/xmlns:archdesc/xmlns:bibliography')
    end

    describe 'class methods:' do
      context 'given as argument a <bibliography> containing a <head>' do
        it '.head_node_set class method returns correct information' do
          value = Ead::Elements::Bibliography.head_node_set(@nokogiri_node_set.first)[0]
          expect(value.text).to eq 'Publications About Described Materials'
        end
      end
      context 'given as argument a <bibliography> containing two <p>' do
        it '.p_node_set class method returns correct information' do
          value = Ead::Elements::Bibliography.p_node_set(@nokogiri_node_set.first)[0]
          expect(value.text).to eq "Cosenza, Mario Emilio. Dictionary of the Italian Humanists."
        end
        it '.p_node_set class method returns correct information' do
          value = Ead::Elements::Bibliography.p_node_set(@nokogiri_node_set.first)[1]
          expect(value.text).to eq 'Anonymous. The title is missing.'
        end
      end
      context 'given as argument a <bibliography> containing two <bibref><title> instances' do
        it '.bibref_title_node_set class method returns correct information' do
          value = Ead::Elements::Bibliography.bibref_title_node_set(@nokogiri_node_set[1])[0]
          expect(value.text).to eq %q("Pis'ma M. I. TSvetaevoi k A. V. Bakhrakhu.": pp. 21U-253, No. 181 (1990).)
        end
        it '.bibref_title_node_set class method returns correct information' do
          value = Ead::Elements::Bibliography.bibref_title_node_set(@nokogiri_node_set[1])[1]
          expect(value.text).to eq %q("Perepiska V.F. KHodasevicha s A.V. Bakhrakhom." No-voe Literaturnoe Obozrezie no. 2 (1993) pp. 107-205.)
        end
      end
    end
  end
end
