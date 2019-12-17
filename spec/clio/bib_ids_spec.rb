# Clio::BibIds encapsulates Bib ID functionality (as a set) as it relates to CLIO
require 'rails_helper'
require 'clio/bib_ids'

class_methods = [
  # argument: Bib ID
  # returns: true or false
  :check_data_files,
  # arguments: filename, search string
  # returns: true or false
  :data_file_contains_string?,
  # argument: Bib ID
  # returns: true or false
  :generate_stub?
].freeze


RSpec.describe Clio::BibIds do
  ########################################## API/interface
  describe '-- Validate API/interface --' do
    context 'has instance method' do
      class_methods.each do |class_method|
        it "#{class_method}" do
          expect(subject.class).to respond_to("#{class_method}")
        end
      end
    end
  end  

  ########################################## Functionality
  describe '-- Validate functionality --' do
    describe 'instance method' do
      context 'generate_stub?' do
        context ', given instance of BibIds with @generate_stub nil and bib ID not in data files ,' do
          bibId = 1234

          it 'returns false' do
            truth_value = Clio::BibIds.generate_stub?(bibId)
            expect(truth_value).to eq false
          end
        end

        context ', given instance of BibIds with @generate_stub nil and bib ID in one of the data files ,' do
          bibId = 356761

          it 'returns true' do
            truth_value = Clio::BibIds.generate_stub?(bibId)
            expect(truth_value).to eq true
          end
        end
      end

      context 'data_file_contains_string?' do
        context ', given data file that contains the searched-for for string ,' do
          it 'returns true' do
            data_file = fixture_file_upload('asi/as_solr_data/nnc-a_solr.xml')
            search_string = '<field name="id">ldpd_13262855</field>'
            truth_value = Clio::BibIds.data_file_contains_string?(data_file, search_string)
            expect(truth_value).to eq true
          end
        end

        context ', given data file that does not contain the searched-for for string ,' do
          it 'returns false' do
            data_file = fixture_file_upload('asi/as_solr_data/nnc-rb_solr.xml')
            search_string = '<field name="id">ldpd_13262855</field>'
            truth_value = Clio::BibIds.data_file_contains_string?(data_file, search_string)
            expect(truth_value).to eq false
          end
        end
      end
    end
  end
end
