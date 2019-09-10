# Encoded Archival Description (EAD) element: <archdesc> Archival Description
# EAD specs: https://www.loc.gov/ead/index.html
require 'rails_helper'
require 'ead/elements/archdesc_component_commonality.rb'

common_class_methods = [
  :accessrestrict_head_array, # <accessrestrict><head>
  :accessrestrict_p_array, # <accessrestrict><p>
  :accruals_head_array, # <accruals><head>
  :accruals_p_array, # <accruals><p>
  :acqinfo_head_array, # <acqinfo><head>
  :acqinfo_p_array, # <acqinfo><p>
  :altformavail_head_array,  # <altformavail><head>
  :altformavail_p_array, # <altformavail><p>
  :arrangement_head_array, # <arrangement><head>
  :arrangement_p_array, # <arrangement><p>
  :bioghist_head_array, # <bioghist><head>
  :bioghist_p_array, # <bioghist><p>
  :controlaccess_array, # <controlaccess>
  :custodhist_head_array, # <custodhist><head>
  :custodhist_p_array, # <custodhist><p>
  :did, # <did>
  :dsc, # <dsc>
  :odd_head_array, # <odd><head>
  :odd_p_array, # <odd><p>
  :otherfindaid_head_array, # <otherfindaid><head>
  :otherfindaid_p_array, # <otherfindaid><p>
  :prefercite_head_array, # <prefercite><head>
  :prefercite_p_array, # <prefercite><p>
  :processinfo_head_array, # <processinfo><head>
  :processinfo_p_array, # <processinfo><p>
  :relatedmaterial_head_array, # <relatedmaterial><head>
  :relatedmaterial_p_array, # <relatedmaterial><p>
  :scopecontent_head_array, # <scopecontent><head>
  :scopecontent_p_array, # <scopecontent><p>
  :separatedmaterial_head_array, # <separatedmaterial><head>
  :separatedmaterial_p_array, # <separatedmaterial><p>
  :userestrict_head_array, # <userestrict><head>
  :userestrict_p_array # <userestrict><p>
].freeze


RSpec.describe Ead::Elements::ArchdescComponentCommonality do
  ########################################## API/interface
  describe 'API/interface' do
    context 'has class method' do
      common_class_methods.each do |common_class_method|
        it "#{common_class_method}" do
          expect(subject.class).to respond_to("#{common_class_method}")
        end
      end
    end
  end
end
