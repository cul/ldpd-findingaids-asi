require 'rails_helper'

describe Repository, type: :model do
  subject(:repository) { described_class.find(repository_id) }
  let(:repository_id) { 'nnc-a' }

  describe '.pluck' do
    it 'returns a list of repository keys' do
      expect(described_class.pluck(:id)).to eql(REPOS.keys)
    end
  end

  describe '.find' do
    it 'raises on unconfigured id' do
      expect { described_class.find('nonexistent') }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#name' do
    it "returns configured value" do
      expect(repository.name).to eql('Avery Drawings & Archives Collections')
    end
  end

  describe '#url' do
    it "returns configured value" do
      expect(repository.url).to eql('https://findingaids.library.columbia.edu/ead/nnc-a')
    end
  end

  describe '#as_repo_id' do
    it "returns configured value" do
      expect(repository.as_repo_id).to eql(3)
    end
  end

  describe '#has_fa_list?' do
    it "returns configured value" do
      expect(repository.has_fa_list?).to be true
    end
  end

  describe '#aeon_enabled?' do
    it "returns true when requestable_via_aeon is configured" do
      expect(repository.aeon_enabled?).to be true
    end
    context "requestable_via_aeon is false" do
      let(:repository_id) { 'nynycoh' }
      it "returns false" do
        expect(repository.aeon_enabled?).to be false
      end
    end
  end

  describe '#aeon_site_code' do
    it "returns configured value" do
      expect(repository.aeon_site_code).to eql 'AVERYDACUL'
    end
    context "requestable_via_aeon is false" do
      let(:repository_id) { 'nynycoh' }
      it "returns nil" do
        expect(repository.aeon_site_code).to be_nil
      end
    end
  end

  describe '#request_config_for_type' do
    let(:request_type) { 'aeon_local_request' }
    let(:request_config_for_type) { repository.request_config_for_type(request_type) }
    it "returns configuration when requestable_via_aeon is configured" do
      expect(request_config_for_type).to be_present
    end
    context 'unconfigured request type' do
      let(:request_type) { 'nynycoh_request' }
      it "returns empty configuration" do
        expect(request_config_for_type).to be_empty
      end
    end
    context "requestable_via_aeon is false" do
      let(:repository_id) { 'nynycoh' }
      it "returns empty configuration" do
        expect(request_config_for_type).to be_empty
      end
    end
  end
end
