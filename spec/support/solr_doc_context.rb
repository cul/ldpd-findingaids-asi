shared_context "empty solr_doc" do
  let(:solr_doc) { SolrDocument.new({}) }
end

shared_context "nil solr_doc" do
  let(:solr_doc) { nil }
end