require 'rails_helper'

RSpec.describe ComponentsController, type: :controller do
  # fcd1, 04/12/19: Can't figure out a way to make the following
  # work with nested resource within finding aids within repositories  
  let(:repo_code) { "nnc-a" }
  let(:repository) { Arclight::Repository.find_by(slug: repo_code).dup }
  before do
    # side effects!
    allow(controller).to receive(:validate_bid_id_and_set_repo_id).and_wrap_original do |_mock_resp, *_args|
      controller.instance_variable_set(:@repository, repository)
    end
  end

  describe "GET #index" do
    let(:well_known_bib_id) { '8972723' }

    it "returns http success" do
      get :index, params: { finding_aid_id: "ldpd_#{well_known_bib_id}", repository_id: repo_code }
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
    before do
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
    describe "show action" do
      before do
        get :show, params: { finding_aid_id: "ldpd_#{well_known_bib_id}", repository_id: repo_code, id: well_known_id }
      end
      it "sets @subjects attribute" do
        expect(response).to have_http_status(:success)
        subjects_att = controller.instance_variable_get(:@subjects)
        expect(subjects_att).to eql expected_subjects
      end
      describe '@user_review_value' do
        let(:repository) do
          _dr = Arclight::Repository.find_by(slug: repo_code).dup
          _dr.attributes.merge!(:aeon_user_review_set_to_yes => aeon_user_review_set_to_yes_config)
          _dr
        end

        let(:user_review_value) { controller.instance_variable_get(:@user_review_value) }

        context "repository configured for user review" do
          let(:aeon_user_review_set_to_yes_config) { true }
          it "sets @user_review_value to 'yes'" do
            expect(user_review_value).to eq('yes') 
          end
        end
        context "repository configured without user review" do
          let(:aeon_user_review_set_to_yes_config) { false }
          it "sets @user_review_value to 'no'" do
            expect(user_review_value).to eql 'no' 
          end
        end
      end
    end
  end

end
