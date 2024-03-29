# frozen_string_literal: true

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  # Override Blacklight helper to prevent session tracking external links
  def link_to_document(doc, field_or_opts = nil, opts = { counter: nil })
    label = case field_or_opts
            when NilClass
              document_presenter(doc).heading
            when Hash
              opts = field_or_opts
              document_presenter(doc).heading
            else # String
              field_or_opts
            end
    doc_link = search_state.url_for_document(doc)
    link_html_opts = doc_link.is_a?(String) ? { target: '_blank', class: "external-link", rel: "noopener noreferrer" } : document_link_params(doc, opts)
    link_to label, doc_link, link_html_opts
  end
end