require 'rails_helper'

describe Acfa::ShowPresenter, type: :unit do
  subject(:presenter) { described_class.new(document, view_context, view_config: view_config) }
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:view_config) { blacklight_config.view_config(:show) }
  let(:view_context) { double(blacklight_config: blacklight_config) }
  let(:document) { instance_double(SolrDocument).as_null_object }

  describe '#html_title' do
    let(:doc_title) { "Component Title" }
    let(:repo_name) { "Repository Name" }

    before do
      allow(presenter).to receive(:heading).and_return(doc_title)
      allow(document).to receive(:fetch).with("repository_ssim", nil).and_return([repo_name])
    end

    it "returns the combined component title and repository name" do
      expected_title = "Component Title - Repository Name"
      expect(presenter.html_title).to eq(expected_title)
    end

  end

end