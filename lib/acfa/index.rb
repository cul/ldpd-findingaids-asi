module Acfa::Index
  def self.build_suggester(solr_url)
    `curl #{solr_url}suggest?suggest.build=true`
  end
end