# frozen_string_literal: true

def extents_per_physdesc(physdescs_nodes)
  physdescs_nodes.map do |physdesc|
    extents = physdesc.xpath('./extent').map { |e| e.text.strip }
    # Add parenthesis to last extent in list
    extents[-1] = "(#{extents[-1]})" if extents&.length > 1
    # Join extents within the same physdesc with an empty string
    extents.join(' ')
  end
end

# Replace bibref tags with paragraph tags to add spacing between elements
def process_bibliography_content(content_elements)
  content_elements.map do |element|
    element_string = element.to_s

    # Replace <bibref> with <p> and </bibref> with </p>
    element_string.gsub!(/<bibref([^>]*)>/, '<p\1>')
    element_string.gsub!(/<\/bibref>/, '</p>')

    element_string
  end.join("\n")
end  

def semantic_search_source_text(traject_context)
  title = traject_context.output_hash['normalized_title_ssm']&.join(', ')
  parent_unittitles = traject_context.output_hash['parent_unittitles_ssm']
  collection_name = parent_unittitles.present? ? parent_unittitles.shift : nil

  scopecontent = traject_context.output_hash['scopecontent_tesim']&.join(', ')

  content_as_embeddings = ''
  content_as_embeddings += "This is a part of #{collection_name}.  " if collection_name.present?
  content_as_embeddings += "This record is labeled \"#{title}\"" # Always assume we have a title
  if parent_unittitles.present?
    content_as_embeddings += " and organized in that collection under the headings:\n"
    parent_unittitles.each do |level|
      content_as_embeddings += "#{level}\n"
    end
  else
    content_as_embeddings += '.  '
  end

  content_as_embeddings += scopecontent unless scopecontent.blank?

  content_as_embeddings
end

def get_model_identifier
  CONFIG[:vector_search_model_key]
end

