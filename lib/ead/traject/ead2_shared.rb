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
