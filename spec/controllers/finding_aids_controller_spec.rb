require 'rails_helper'

RSpec.describe FindingAidsController, type: :controller do
  # fcd1, 04/12/19: Can't figure out a way to make the following
  # work with nested resource within repositories
  xdescribe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  xdescribe "GET #show" do
    it "returns http success" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  before(:context) do
    @xml_input = fixture_file_upload('ead/test_ead.xml').read
  end

  describe 'create_nokogiri_xml_document' do
    it 'create_nokogiri_xml_document' do
      nokogiri_doc = subject.create_nokogiri_xml_document @xml_input
      expect(nokogiri_doc).to be_instance_of Nokogiri::XML::Document
    end
  end
end
