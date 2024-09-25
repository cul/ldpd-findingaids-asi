require 'rails_helper'

describe SolrDocument, type: :model do
  let(:id) { "ldpd_#{bibid}_aspace_abcdefabcdefabcdefabcdefabcdefab" }
  let(:bibid) { '12345678' }
  let(:title_ssm) { ['Great Title'] }
  let(:creator_ssim) { ['Great Author'] }
  let(:normalized_date_ssm) { ['07-20-1969'] }
  let(:repository_id) { 'nnc-rb' }
  let(:parent_access_restrict_tesm_value) { ['unprocessed material'] }
  let(:barcode) { 'RH00002380' }
  let(:box_label) { 'box 230' }
  let(:folder_label) { 'folder 1 to 3' }
  let(:parent_unittitles_ssm) { ['First value', 'Series 2'] }
  let(:call_number) { 'MS#1234' }
  let(:container_information_ssm) do
    [
      {
        'barcode' => barcode,
        'id' => 'ef18c12f57c6c1c39c2f2ece677e6070',
        'parent' => '',
        'label' => box_label,
        'type' => 'box',
      }.to_json,
      {
        'barcode' => nil,
        'id' => 'b4ed1e77add4128f44588571fcd85b7e',
        'parent' => 'ef18c12f57c6c1c39c2f2ece677e6070',
        'label' => folder_label,
        'type' => 'folder'
      }.to_json
    ]
  end
  let(:containers_ssim) do
    container_information_ssm.map {|container_info| container_info['label'] }
  end
  let(:aeon_unavailable_for_request_ssi) { false }

  let(:solr_doc) do
    described_class.new({
      'id' => id,
      'title_ssm' => title_ssm,
      'creator_ssim' => creator_ssim,
      'normalized_date_ssm' => normalized_date_ssm,
      'repository_id_ssi' => repository_id,
      'parent_access_restrict_tesm' => parent_access_restrict_tesm_value,
      'container_information_ssm' => container_information_ssm,
      'containers_ssim' => containers_ssim, # This backs the Arclight SolrDocument#containers method
      'parent_unittitles_ssm' => parent_unittitles_ssm,
      'call_number_ss' => call_number,
      'aeon_unavailable_for_request_ssi' => aeon_unavailable_for_request_ssi,
    })
  end

  describe '#requestable?' do
    it  "returns true when the solr_document's repository allows requests, and the record has a parent container, "\
        "and the record is not otherwise marked as unavailable" do
      expect(solr_doc.requestable?).to eq(true)
    end

    context "when the repository does not allow requests" do
      before do
        allow(solr_doc.repository_config).to receive(:request_types).and_return([])
      end
      it "returns false" do
        expect(solr_doc.requestable?).to eq(false)
      end
    end

    context "when the record has no parent containers" do
      let(:container_information_ssm) { [] }
      it "returns false" do
        expect(solr_doc.requestable?).to eq(false)
      end
    end

    context "when the record is marked as unavailable" do
      let(:aeon_unavailable_for_request_ssi) { true }
      it "returns false" do
        expect(solr_doc.requestable?).to eq(false)
      end
    end
  end
end
