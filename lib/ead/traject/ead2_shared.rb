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
def process_bibliography_element(bib_node)
  bib_string = bib_node.to_s

  # Replace <bibref> with <p> and </bibref> with </p>
  bib_string.gsub!(/<bibref([^>]*)>/, '<p\1>')
  bib_string.gsub!(/<\/bibref>/, '</p>')

  bib_string
end
