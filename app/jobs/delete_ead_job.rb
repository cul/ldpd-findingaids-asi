class DeleteEadJob < ApplicationJob
  def perform(bibid)
    solr_con = Blacklight.default_index.connection
    solr_con.delete_by_query "_root_:#{bibid}"
    solr_con.commit(softCommit: true)
    solr_url = solr_con.base_uri
    Acfa::Index.build_suggester(solr_url)
    1
  end
end
