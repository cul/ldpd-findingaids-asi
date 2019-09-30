# Encoded Archival Description (EAD) element: <archdesc> Archival Description
# EAD specs: https://www.loc.gov/ead/index.html
require 'rails_helper'
require 'ead/elements/archdesc_component_commonality.rb'

common_class_methods = [
  :accessrestrict_head_node_set, # <accessrestrict><head>
  :accessrestrict_p_node_set, # <accessrestrict><p>
  :accruals_head_node_set, # <accruals><head>
  :accruals_p_node_set, # <accruals><p>
  :acqinfo_head_node_set, # <acqinfo><head>
  :acqinfo_p_node_set, # <acqinfo><p>
  :altformavail_head_node_set,  # <altformavail><head>
  :altformavail_p_node_set, # <altformavail><p>
  :arrangement_head_node_set, # <arrangement><head>
  :arrangement_p_node_set, # <arrangement><p>
  :bioghist_head_node_set, # <bioghist><head>
  :bioghist_p_node_set, # <bioghist><p>
  :controlaccess_node_set, # <controlaccess>
  :custodhist_head_node_set, # <custodhist><head>
  :custodhist_p_node_set, # <custodhist><p>
  :did_node_set, # <did>
  :dsc_node_set, # <dsc>
  :level_attribute_node_set, # <c level= >
  :odd_head_node_set, # <odd><head>
  :odd_p_node_set, # <odd><p>
  :otherfindaid_head_node_set, # <otherfindaid><head>
  :otherfindaid_p_node_set, # <otherfindaid><p>
  :prefercite_head_node_set, # <prefercite><head>
  :prefercite_p_node_set, # <prefercite><p>
  :processinfo_head_node_set, # <processinfo><head>
  :processinfo_p_node_set, # <processinfo><p>
  :relatedmaterial_head_node_set, # <relatedmaterial><head>
  :relatedmaterial_p_node_set, # <relatedmaterial><p>
  :scopecontent_head_node_set, # <scopecontent><head>
  :scopecontent_p_node_set, # <scopecontent><p>
  :separatedmaterial_head_node_set, # <separatedmaterial><head>
  :separatedmaterial_p_node_set, # <separatedmaterial><p>
  :userestrict_head_node_set, # <userestrict><head>
  :userestrict_p_node_set # <userestrict><p>
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
