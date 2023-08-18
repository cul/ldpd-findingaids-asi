require 'rails_helper'

RSpec.describe FindingAidsController, type: :controller do
  # fcd1, 04/12/19: Can't figure out a way to make the following
  # work with nested resource within repositories
  describe "GET #index" do
    let(:repository_id) { "nnc-a" }
    it "returns http success" do
      get :index, params: { repository_id: repository_id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "setting subject attributes" do
    let(:fixture_path) { File.join(file_fixture_path, '../../test/fixtures/files/ead/as_ead_ldpd_8972723.xml') }
    let(:fixture_data) { File.read(fixture_path) }
    let(:well_known_bib_id) { '8972723' }
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
    before do
      allow(controller).to receive(:render_cached_html_else_return_as_ead_xml).with(well_known_bib_id.to_i).and_return(fixture_data)
      controller.params[:id] = "ldpd_#{well_known_bib_id}"
    end
    context "print action" do
      it "sets @subjects attribute" do
        get :print, params: { finding_aid_id: "ldpd_#{well_known_bib_id}", repository_id: "nnc-a" }
        expect(response).to have_http_status(:success)
        subjects_att = controller.instance_variable_get(:@subjects)
        expect(subjects_att).to eql expected_subjects
      end
    end
    context "show action" do
      it "sets @subjects attribute" do
        get :show, params: { id: "ldpd_#{well_known_bib_id}", repository_id: "nnc-a" }
        expect(response).to have_http_status(:success)
        subjects_att = controller.instance_variable_get(:@subjects)
        expect(subjects_att).to eql expected_subjects
      end
    end
  end
end
