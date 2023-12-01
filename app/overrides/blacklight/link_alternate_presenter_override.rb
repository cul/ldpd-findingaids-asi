# frozen_string_literal: true

Blacklight::LinkAlternatePresenter.class_eval do
  # core Blacklight uses polymorphic_url despite the fact that these are routing params and not an ActiveModel
  # use url_for instead, unless it's a URI
  def href(format)
    url_or_params = view_context.search_state.url_for_document(document)
    String === url_or_params ? url_or_params : view_context.url_for(url_or_params.merge(format: format))
  end
end
