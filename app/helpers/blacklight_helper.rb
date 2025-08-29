# frozen_string_literal: true

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  # Override Blacklight helper to prevent session tracking external links
  # and to use HTML-formatted titles from normalized_title method
  def link_to_document(doc, field_or_opts = nil, opts = { counter: nil })
    label = case field_or_opts
            when NilClass
              # Use the SolrDocument's label which uses normalized_title
              document_presenter(doc).label
            when Hash
              opts = field_or_opts
              # Use the SolrDocument's label which uses normalized_title
              document_presenter(doc).label
            else # String
              field_or_opts
            end
    doc_link = search_state.url_for_document(doc)
    link_html_opts = doc_link.is_a?(String) ? { target: '_blank', class: "external-link", rel: "noopener noreferrer" } : document_link_params(doc, opts)
    link_to label&.html_safe, doc_link, link_html_opts
  end
end