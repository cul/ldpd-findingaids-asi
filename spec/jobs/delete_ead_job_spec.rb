require 'rails_helper'

RSpec.describe DeleteEadJob do
  let(:delete_ead_job) { described_class.new }
  let(:bibid) { 123456789 }
  let(:solr_con) { Blacklight.default_index.connection }

  describe '#perform' do
    it 'deletes the given bibid record from the solr index, builds a suggester, and returns the expected value' do
      expect(solr_con).to receive(:delete_by_query).with("_root_:#{bibid}")
      expect(solr_con).to receive(:commit).with(softCommit: true)
      expect(Acfa::Index).to receive(:build_suggester).and_call_original
      expect(delete_ead_job.perform(bibid)).to eq(1)
    end
  end
end
