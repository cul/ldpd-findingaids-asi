# frozen_string_literal: true

Blacklight::LinkAlternatePresenter.class_eval do
  # core Blacklight uses polymorphic_url despite the fact that these are routing params and not an ActiveModel
  # use url_for instead, unless it's a URI
  def href(format)
    url_or_params = view_context.search_state.url_for_document(document)
    case url_or_params
    when String
      return url_or_params
    # NOTE: For the `when` case below, we're comparing the class to `Blacklight::Solr::Document` rather than just
    # `SolrDocument` to work around a class reloading issue (which only affects the development environment).
    # If we were to instead compare with `SolrDocument`, the check would fail on show pages in the development
    # environment after an autoload class reload, because SolrDocument (which is one of our app's autoloaded classes)
    # gets reloaded and the `SolrDocument` class instance is different after the reload.
    when Blacklight::Solr::Document
      return { id: url_or_params, format: format }
    else
      return view_context.url_for(url_or_params.merge(format: format))
    end
  end
end
