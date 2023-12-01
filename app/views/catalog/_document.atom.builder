# frozen_string_literal: true

presenter = document_presenter(document)
xml.entry do
  xml.title presenter.heading

  # updated is required, for now we'll just set it to now, sorry
  xml.updated Time.current.iso8601

  # core Blacklight uses polymorphic_url despite the fact that these are routing params and not an ActiveModel
  # use url_for instead, unless it's a URI
  url_or_params = search_state.url_for_document(document)
  url_for_document = String === url_or_params ? url_or_params.to_s : url_for(url_or_params)
  xml.link "rel" => "alternate", "type" => "text/html", "href" => url_for_document
  # add other doc-specific formats, atom only lets us have one per
  # content type, so the first one in the list wins.
  xml << presenter.link_rel_alternates(unique: true)

  xml.id url_for_document

  if document.to_semantic_values.key? :author
    xml.author { xml.name(document.to_semantic_values[:author].first) }
  end

  with_format(:html) do
    xml.summary "type" => "html" do
      document_component = blacklight_config.view_config(:atom).summary_component
      xml.text! render document_component.new(document_component.collection_parameter => document_presenter(document), component: :div, show: true)
    end
  end

  # If they asked for a format, give it to them.
  if (params["content_format"] &&
    document.export_formats[params["content_format"].to_sym])

    type = document.export_formats[params["content_format"].to_sym][:content_type]

    xml.content type: type do |content_element|
      data = document.export_as(params["content_format"])

      # encode properly. See:
      # http://tools.ietf.org/html/rfc4287#section-4.1.3.3
      type = type.downcase
      case type.downcase
      when %r{\+|/xml$}
        # xml, just put it right in
        content_element << data
      when %r{text/}
        # text, escape
        content_element.text! data
      else
        # something else, base64 encode it
        content_element << Base64.encode64(data)
      end
    end

  end
end