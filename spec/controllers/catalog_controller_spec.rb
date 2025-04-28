require 'rails_helper'

RSpec.describe CatalogController, type: :controller do

  describe "GET #resolve" do
    let(:id) { '123456789' }
    let(:bib_id) { '123456789' }
    let(:solr_id) { 'cul-123456789' }
    let(:repository_id) { 'nnc' }
    let(:search_service) { instance_double(Blacklight::SearchService) }
    let(:solr_doc) { {id: solr_id, repository_id_ssi: repository_id} }
    let(:finding_aid_url) { "/archives/#{solr_id}" }
    let(:clio_url) { "https://clio.columbia.edu/catalog/#{bib_id}" }
    before do
      allow(controller).to receive(:search_service).and_return(search_service)
      allow(search_service).to receive(:fetch).with(solr_id).and_return(solr_doc)
    end
    it "redirects to finding aid" do
      expect(controller).to receive(:redirect_to).with(finding_aid_url).and_call_original
      get :resolve, params: { id: id }
      expect(response).to have_http_status(:found)
    end
    context "doc was not found" do
      before do
        allow(search_service).to receive(:fetch).with(solr_id).and_raise(Blacklight::Exceptions::RecordNotFound)
      end
      it "redirects to CLIO http found" do
        expect(controller).to receive(:redirect_to).with(clio_url, allow_other_host: true).and_call_original
        get :resolve, params: { id: id }
        expect(response).to have_http_status(:found)
      end
      context "and id did not appear to be a bib id" do
        let(:id) { 'BA-123456789' }
        let(:solr_id) { id }
        it "raises not found exception" do
          expect { get(:resolve, params: { id: id }) }.to raise_error(Blacklight::Exceptions::RecordNotFound)
        end
      end
    end
    context "id has ldpd prefix" do
      let(:id) { 'cul-123456789' }
      it "redirects to finding aid" do
        expect(controller).to receive(:redirect_to).with(finding_aid_url).and_call_original
        get :resolve, params: { id: id }
        expect(response).to have_http_status(:found)
      end
    end
    context "id is blank" do
      let(:id) { '' }
      it "redirects to root" do
        expect(controller).to receive(:redirect_to).with("/").and_call_original
        get :resolve, params: { id: id }
        expect(response).to have_http_status(:found)
      end
    end
  end
end
