require 'rails_helper'
require 'acfa/index.rb'

RSpec.describe Acfa::Index do
  describe ".build_suggester" do
    let(:example_solr_url) { 'https://example.com:12345' }
    it "works as expected" do
      expect(described_class).to receive(:`).with("curl #{example_solr_url}suggest?suggest.build=true")
      described_class.build_suggester(example_solr_url)
    end
  end
end
