require 'rails_helper'

RSpec.describe ComponentsController, type: :controller do
  # fcd1, 04/12/19: Can't figure out a way to make the following
  # work with nested resource within finding aids within repositories  
  describe "GET #index" do
    let(:well_known_bib_id) { '8972723' }
    before do
      allow(controller).to receive(:validate_bid_id_and_set_repo_id)
    end
    it "returns http success" do
      get :index, params: { finding_aid_id: "ldpd_#{well_known_bib_id}", repository_id: "nnc-a" }
      expect(response).to have_http_status(:success)
    end
  end

  describe "setting subject attributes" do
    let(:fixture_path) { File.join(file_fixture_path, '../../test/fixtures/files/ead/as_ead_ldpd_8972723.xml') }
    let(:fixture_data) { File.read(fixture_path) }
    let(:well_known_bib_id) { '8972723' }
    let(:well_known_id) { 1 }
    let(:genres) {
      [
        "Albums (books)",
        "Brochures",
        "Ledgers (account books)",
        "Photographs"
      ].sort
    }
    let(:names) {
      [
        "Rose Associates, Inc",
        "Eastmore Realty Corporation",
        "Gramercy Development Corporation",
        "Jackson Development Corporation"
      ].sort
    }
    let(:places) {
      [
        "New York (N.Y.) -- Buildings, structures, etc",
        "Manhattan (New York, N.Y.) -- Buildings, structures, etc"
      ].sort
    }
    let(:subjects) {
      [
        "Apartment houses -- New York (State) -- New York",
        "Architects -- New York (State) -- New York",
        "Buildings -- New York (State) -- New York",
        "Real estate management -- New York (State) -- New York",
        "Real estate business -- New York (State) -- New York"
      ].sort
    }
    let(:expected_subjects) { subjects.sort }
    let(:repo_code) { "nnc-a" }
    before do
      allow(controller).to receive(:validate_bid_id_and_set_repo_id)
      controller.instance_variable_set(:@repository, Arclight::Repository.find_by(slug: repo_code))
      allow(controller).to receive(:render_cached_html_else_return_as_ead_xml).with(well_known_bib_id.to_i, anything).and_return(fixture_data)
      controller.params[:id] = well_known_id
    end
    context "print action" do
      it "sets @subjects attribute" do
        get :index, params: { finding_aid_id: "ldpd_#{well_known_bib_id}", repository_id: "nnc-a" }
        expect(response).to have_http_status(:success)
        subjects_att = controller.instance_variable_get(:@subjects)
        expect(subjects_att).to eql expected_subjects
      end
    end
    context "show action" do
      it "sets @subjects attribute" do
        get :show, params: { finding_aid_id: "ldpd_#{well_known_bib_id}", repository_id: repo_code, id: well_known_id }
        expect(response).to have_http_status(:success)
        subjects_att = controller.instance_variable_get(:@subjects)
        expect(subjects_att).to eql expected_subjects
      end
    end
  end

end
