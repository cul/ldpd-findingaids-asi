require 'rails_helper'
require 'ead/elements/controlaccess.rb'

class_methods = [
  :corpname_array, # <corpname> Corporate Name
  :genreform_array, # <genreform> Genre/Physical Characteristic
  :geogname_array, # <geogname> Geographic Name
  :occupation_array, # <occupation> Occupation
  :persname_array, # <persname> Personal Name
  :subject_array # <subject> Subject
].freeze


RSpec.describe Ead::Elements::Controlaccess do
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
      @nokogiri_node_set = Nokogiri::XML(input_xml).xpath('/xmlns:ead/xmlns:archdesc/xmlns:controlaccess')
    end

    describe ' class methods that return an array:' do
      context 'class method' do
        # <corpname> Corporate Name
        let (:expected_corpname_array) {
          [
            'Barnard College',
            'Simon and Schuster, Inc'
          ]
        }

        # <genreform> Genre/Physical Characteristic
        let (:expected_genreform_array) {
          [
            'Illustrations',
            'Initials'
          ]
        }

        # # <geogname> Geographic Name
        let (:expected_geogname_array) {
          [
            'Russia -- History -- 1801-1917',
            'Belgium -- History -- 1914-1918'
          ]
        }

        # <occupation> Occupation
        let (:expected_occupation_array) {
          [
            'Artists',
            'Cartoonists'
          ]
        }

        # <persname> Personal Name
        let (:expected_persname_array) {
          [
            'Fritz, Chester',
            'Tong, Te-kong, 1920-2009'
          ]
        }

        # <subject> Subject
        let (:expected_subject_array) {
          [
            'Art',
            'Drawing'
          ]
        }

        class_methods.each do |class_method|
          it ".#{class_method} takes a <did> and returns an array of <#{class_method.to_s.chomp('_array')}>" do
            values = Ead::Elements::Controlaccess.send(class_method,@nokogiri_node_set)
            expected_values = eval "expected_#{class_method}"
            expected_values.each_with_index do |expected_value, index|
              expect(values[index].text).to eq expected_value
            end
          end
        end
      end
    end
  end
end
