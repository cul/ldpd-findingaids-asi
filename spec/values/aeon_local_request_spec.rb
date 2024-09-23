require 'rails_helper'

RSpec.describe AeonLocalRequest do
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
  let(:solr_doc) do
    SolrDocument.new({
      'id' => id,
      'title_ssm' => title_ssm,
      'creator_ssim' => creator_ssim,
      'normalized_date_ssm' => normalized_date_ssm,
      'repository_id_ssi' => repository_id,
      'parent_access_restrict_tesm' => parent_access_restrict_tesm_value,
      'container_information_ssm' => container_information_ssm,
      'parent_unittitles_ssm' => parent_unittitles_ssm,
      'call_number_ss' => call_number
    })
  end
  let(:aeon_local_request) { described_class.new(solr_doc) }

  describe '#initialize' do
    it 'can be instantiated' do
      expect(aeon_local_request).to be_a(described_class)
    end
  end

  describe '#repository_config' do
    it 'returns the expected repository config value' do
      expect(aeon_local_request.repository_config.attributes['name']).to eq('Rare Book & Manuscript Library')
    end
  end

  describe '#repository_local_request_config' do
  it 'returns the expected local request config' do
    expect(aeon_local_request.repository_local_request_config).to eq(
      {'site_code' => 'RBMLCUL', 'user_review' => true}
      )
    end
  end

  describe '#unprocessed?' do
    context "for a processed record" do
      let(:parent_access_restrict_tesm_value) { ['processed material'] }
      it 'returns false' do
        expect(aeon_local_request.unprocessed?).to eq(false)
      end
    end
    context "for an unprocessed record" do
      it 'returns true' do
        expect(aeon_local_request.unprocessed?).to eq(true)
      end
    end
  end

  describe '#grouping_field_value' do
    context "when the top level container is a mapcase and a second level container is present" do
      let(:mapcase_label) { 'mapcase 15-J-8' }
      let(:container_information_ssm) do
        [
          {
            'barcode' => nil,
            'id' => 'aspace_cebc1ce953260203b3ed07954e79541f',
            'parent' => '',
            'label' => mapcase_label,
            'type' => 'mapcase',
          }.to_json,
          {
            'barcode' => nil,
            'id' => 'aspace_1908a16b0b79277ce166a6efe43a2ab2',
            'parent' => 'aspace_cebc1ce953260203b3ed07954e79541f',
            'label' => 'folder 3',
            'type' => 'folder'
          }.to_json
        ]
      end
      it 'returns the second level container, prefixed with "mapcase, "' do
        expect(aeon_local_request.grouping_field_value).to eq('mapcase, folder 3')
      end
    end
    context "when the top level container is NOT a mapcase" do
      it 'returns the top level container' do
        expect(aeon_local_request.grouping_field_value).to eq(box_label)
      end
    end
    context "when the top level container is a mapcase, but there is no second level container" do
      let(:mapcase_label) { 'mapcase 15-J-8' }
      let(:container_information_ssm) do
        [
          {
            'barcode' => nil,
            'id' => 'aspace_cebc1ce953260203b3ed07954e79541f',
            'parent' => '',
            'label' => mapcase_label,
            'type' => 'mapcase',
          }.to_json,
        ]
      end
      it 'returns the top level container' do
        expect(aeon_local_request.grouping_field_value).to eq(mapcase_label)
      end
    end
  end

  describe '#reference_number' do
  context "when the record id matches our expected bibid id pattern" do
    it 'extracts the bibid' do
      expect(aeon_local_request.reference_number).to eq(bibid)
    end
  end
  context "when the record id does NOT matche our expected bibid id pattern" do
    let(:id) { 'no_match_here' }

    it 'returns nil' do
      expect(aeon_local_request.reference_number).to eq(nil)
    end
  end
end

  describe '#container_information' do
    it "returns the json-parsed version of the underlying container json data" do
      expect(aeon_local_request.container_information).to eq(
        container_information_ssm.map { |container_information_json| JSON.parse(container_information_json) }
        )
      end
    end

    describe '#barcode' do
    it "returns the expected value" do
      expect(aeon_local_request.barcode).to eq(barcode)
    end
  end

  describe '#series' do
    context "when parent_unittitles_ssm has at least two levels" do
      it 'returns the second level as the series value' do
        expect(aeon_local_request.series).to eq(parent_unittitles_ssm[1])
      end
    end
    context "when parent_unittitles_ssm has fewer than two levels" do
      let(:parent_unittitles_ssm) { ['only one level'] }

      it 'returns nil' do
        expect(aeon_local_request.series).to eq(nil)
      end
    end
  end

  describe '#call_number' do
    it 'returns the expected value' do
      expect(aeon_local_request.call_number).to eq(call_number)
    end
  end

  describe '#form_attributes' do
    let(:expected_form_attributes) do
      {
        'Site' => 'RBMLCUL',
        'ItemTitle' => title_ssm.first,
        'ItemDate' => normalized_date_ssm.first,
        'ReferenceNumber' => '12345678',
        'DocumentType' => 'All',
        'ItemInfo1' => 'Archival Materials',
        'ItemInfo3' => 'UNPROCESSED',
        'UserReview' => 'Yes',
        'ItemVolume' => 'box 230',
        'ItemNumber' => 'RH00002380',
        'ItemSubTitle' => 'Series 2',
        'CallNumber' => 'MS#1234',
        'Location' => 'Rare Book & Manuscript Library',

      }
    end

    it 'generates the expected attributes' do
      expect(aeon_local_request.form_attributes).to eq(expected_form_attributes)
    end
  end
end
