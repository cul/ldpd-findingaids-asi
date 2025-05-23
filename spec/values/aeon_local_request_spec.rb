require 'rails_helper'

RSpec.describe AeonLocalRequest do
  let(:id) { "cul-#{bibid}_aspace_abcdefabcdefabcdefabcdefabcdefab" }
  let(:bibid) { '12345678' }
  let(:collection_ssim) { ['Great Collection Name'] }
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
  let(:collection_offsite_ssi) { 'false' }
  let(:digital_objects_ssm) { nil }
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
      'collection_ssim' => collection_ssim,
      'title_ssm' => title_ssm,
      'creator_ssim' => creator_ssim,
      'normalized_date_ssm' => normalized_date_ssm,
      'repository_id_ssi' => repository_id,
      'parent_access_restrict_tesm' => parent_access_restrict_tesm_value,
      'container_information_ssm' => container_information_ssm,
      'parent_unittitles_ssm' => parent_unittitles_ssm,
      'call_number_ss' => call_number,
      'collection_offsite_ssi' => collection_offsite_ssi,
      'digital_objects_ssm' => digital_objects_ssm
    })
  end
  let(:aeon_local_request) { described_class.new(solr_doc) }

  describe '#initialize' do
    it 'can be instantiated' do
      expect(aeon_local_request).to be_a(described_class)
    end

    context "when solr_doc has no data" do
      include_context "empty solr_doc"
      it 'can be instantiated' do
        expect(aeon_local_request).to be_a(described_class)
      end
    end

    context "when solr_doc is nil" do
      include_context "nil solr_doc"
      # this class is only instantiated within SolrDocument, which is passed to the initializer
      # and should never be nil
      it 'raises an ArgumentError' do
        expect {aeon_local_request}.to raise_error ArgumentError
      end
    end
  end

  describe '#repository_config' do
    it 'returns the expected repository config value' do
      expect(aeon_local_request.repository_config.attributes['name']).to eq('Rare Book & Manuscript Library')
    end

    context "when solr_doc has no data" do
      include_context "empty solr_doc"

      # upstream logic returns nil when the repository field data is missing
      it 'returns a blank value' do
        expect(aeon_local_request.repository_config).to be_nil
      end
    end
  end

  describe '#repository_local_request_config' do
  it 'returns the expected local request config' do
    expect(aeon_local_request.repository_local_request_config).to eq(
      {'site_code' => 'RBMLCUL', 'user_review' => true}
      )
    end

    context "when solr_doc has no data" do
      include_context "empty solr_doc"
      it 'returns a blank value' do
        expect(aeon_local_request.repository_local_request_config).to be_blank
      end
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

    context "when solr_doc has no data" do
      include_context "empty solr_doc"
      it 'returns false' do
        expect(aeon_local_request.unprocessed?).to eq(false)
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
      it 'returns the second level container, prefixed with top container' do
        expect(aeon_local_request.grouping_field_value).to eq('mapcase 15-J-8, folder 3')
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

    context "when solr_doc has no data" do
      include_context "empty solr_doc"
      it 'returns a blank value' do
        expect(aeon_local_request.grouping_field_value).to be_blank
      end
    end
  end

  describe '#mapcase_or_drawer?' do
    it 'returns true for mapcase' do
      expect(aeon_local_request.mapcase_or_drawer?('mapcase 123')).to eq(true)
    end

    it 'returns true for drawer' do
      expect(aeon_local_request.mapcase_or_drawer?('Drawer 456')).to eq(true)
    end

    it 'returns false for other labels' do
      expect(aeon_local_request.mapcase_or_drawer?('box 789')).to eq(false)
    end
  end

  describe '#reference_number' do
    context "when the record id matches our expected bibid id pattern" do
      it 'extracts the bibid' do
        expect(aeon_local_request.reference_number).to eq(bibid)
      end
    end

    context "when the record id does NOT match our expected bibid id pattern" do
      let(:id) { 'no_match_here' }

      it 'returns nil' do
        expect(aeon_local_request.reference_number).to eq(nil)
      end
    end

    context "when solr_doc has no data" do
      include_context "empty solr_doc"
      it 'returns a blank value' do
        expect(aeon_local_request.reference_number).to be_blank
      end
    end
  end

  describe '#container_information' do
    let(:container_information_json_values) do
      container_information_ssm.map { |container_information_json| JSON.parse(container_information_json) }
    end

    it "returns the json-parsed version of the underlying container json data" do
      expect(aeon_local_request.container_information).to eq(container_information_json_values)
    end

    context "when solr_doc has no data" do
      include_context "empty solr_doc"
      it 'returns a blank value' do
        expect(aeon_local_request.container_information).to be_blank
      end
    end
  end

  describe '#barcode' do
    it "returns the expected value" do
      expect(aeon_local_request.barcode).to eq(barcode)
    end

    context "when solr_doc has no data" do
      include_context "empty solr_doc"
      it 'returns a blank value' do
        expect(aeon_local_request.barcode).to be_blank
      end
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

    context "when solr_doc has no data" do
      include_context "empty solr_doc"
      it 'returns a blank value' do
        expect(aeon_local_request.series).to be_blank
      end
    end
  end

  describe '#call_number' do
    it 'returns the expected value' do
      expect(aeon_local_request.call_number).to eq(call_number)
    end

    context "when solr_doc has no data" do
      include_context "empty solr_doc"
      it 'returns a blank value' do
        expect(aeon_local_request.call_number).to be_blank
      end
    end
  end

  describe '#collection' do
    it 'returns the expected value' do
      expect(aeon_local_request.collection).to eq(collection_ssim.first)
    end

    context "when solr_doc has no data" do
      include_context "empty solr_doc"
      it 'returns a blank value' do
        expect(aeon_local_request.collection).to be_blank
      end
    end
  end

  describe '#title' do
    it 'returns the expected value' do
      expect(aeon_local_request.title).to eq(title_ssm.first)
    end

    context "when solr_doc has no data" do
      include_context "empty solr_doc"
      it 'returns a blank value' do
        expect(aeon_local_request.title).to be_blank
      end
    end
  end

  describe '#location' do
    context 'an item from an onsite collection' do
      let(:collection_offsite_ssi) { 'false' }
      it 'returns the expected value' do
        expect(aeon_local_request.location).to eq('Rare Book & Manuscript Library')
      end
    end

    context 'an item from an offsite collection' do
      let(:collection_offsite_ssi) { 'true' }
      it 'returns the expected value' do
        expect(aeon_local_request.location).to eq('Offsite')
      end
    end

    context "when solr_doc has no data" do
      include_context "empty solr_doc"
      it 'returns a blank value' do
        expect(aeon_local_request.location).to be_blank
      end
    end
  end

  describe '#form_attributes' do
    let(:expected_form_attributes) do
      {
        'Site' => 'RBMLCUL',
        'ItemTitle' => collection_ssim.first,
        'ItemDate' => normalized_date_ssm.first,
        'ReferenceNumber' => '12345678',
        'DocumentType' => 'All',
        'ItemInfo1' => 'Archival Materials',
        'ItemInfo3' => 'UNPROCESSED',
        'UserReview' => 'Yes',
        'ItemVolume' => 'box 230',
        'ItemNumber' => 'RH00002380',
        'ItemSubTitle' => title_ssm.first,
        'CallNumber' => 'MS#1234',
        'Location' => 'Rare Book & Manuscript Library',
      }
    end

    it 'generates the expected attributes' do
      expect(aeon_local_request.form_attributes).to eq(expected_form_attributes)
    end

    context 'when the record is unprocessed, but also has digital content (indicated by the presence of a digital_objects_ssm solr field)' do
      let(:digital_objects_ssm) do
        [{
          label: 'Interview with the members of the photography group En Foco, including Adál (Adál Alberto Maldonado) and Geno Rodriguez, 1974 May 2',
          href: 'https://dx.doi.org/10.7916/gvx3-5b81',
          role: '',
          type: 'simple'
        }].to_json
      end

      it 'sets the ItemInfo3 value to DIGITIZED instead of UNPROCESSED' do
        expect(aeon_local_request.form_attributes['ItemInfo3']).to eq('DIGITIZED')
      end
    end

    context "when solr_doc has no data" do
      let(:expected_form_attributes) do
        {
          'ItemTitle' => nil,
          'ItemDate' => nil,
          'ReferenceNumber' => nil,
          'DocumentType' => 'All',
          'ItemInfo1' => 'Archival Materials',
          'UserReview' => 'Yes',
          'ItemVolume' => nil,
          'ItemNumber' => nil,
          'ItemSubTitle' => nil,
          'CallNumber' => nil,
          'Location' => nil,
        }
      end

      include_context "empty solr_doc"
      it 'returns a blank value' do
        expect(aeon_local_request.form_attributes).to eq(expected_form_attributes)
      end
    end
  end

  describe '#digital?' do
    context 'the underlying solr document has a digital_objects_ssm value' do
      let(:digital_objects_ssm) do
        [{
          label: 'Interview with the members of the photography group En Foco, including Adál (Adál Alberto Maldonado) and Geno Rodriguez, 1974 May 2',
          href: 'https://dx.doi.org/10.7916/gvx3-5b81',
          role: '',
          type: 'simple'
        }].to_json
      end

      it 'returns true' do
        expect(aeon_local_request.digital?).to eq(true)
      end
    end

    context 'the underlying solr document does not have a digital_objects_ssm value' do
      it 'returns false' do
        expect(aeon_local_request.digital?).to eq(false)
      end
    end
  end
end
