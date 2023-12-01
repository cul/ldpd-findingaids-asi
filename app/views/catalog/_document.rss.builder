# frozen_string_literal: true

xml.item do
  xml.title(document_presenter(document).heading || (document.to_semantic_values[:title].first if document.to_semantic_values.key?(:title)))
  # core Blacklight uses polymorphic_url despite the fact that these are routing params and not an ActiveModel
  # use url_for instead, unless it's a URI
  url_or_params = search_state.url_for_document(document)
  url_for_document = String === url_or_params ? url_or_params.to_s : url_for(url_or_params)
  xml.link(url_for_document)
  xml.author(document.to_semantic_values[:author].first) if document.to_semantic_values.key? :author
end