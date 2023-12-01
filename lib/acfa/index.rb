module Acfa::Index
  def self.build_suggester
    `curl #{solr_url}suggest?suggest.build=true`
  end
end
